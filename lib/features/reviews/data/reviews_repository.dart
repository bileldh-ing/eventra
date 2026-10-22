import 'package:drift/drift.dart';
import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/reviews/domain/review.dart';
import 'package:eventra/l10n/l10n.dart';

/// Reviews over raw SQL. Writes re-check every rule, so the UI cannot
/// bypass them: only holders of a valid ticket for an ended event may
/// review, once per event, and only authors may edit or delete.
class ReviewsRepository {
  ReviewsRepository(this.db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final DateTime Function() _clock;
  var _seq = 0;

  static const _seedKey = 'reviews_seeded_v1';

  // ---------------------------------------------------------------- reads

  Future<RatingSummary> summary(String eventId) async {
    final rows = await db
        .customSelect(
          'SELECT rating, COUNT(*) AS c FROM reviews WHERE event_id = ? '
          'GROUP BY rating',
          variables: [Variable.withString(eventId)],
        )
        .get();
    final h = List<int>.filled(5, 0);
    var n = 0;
    for (final r in rows) {
      final stars = r.read<int>('rating');
      final c = r.read<int>('c');
      h[stars - 1] = c;
      n += c;
    }
    return RatingSummary(count: n, histogram: List.unmodifiable(h));
  }

  /// Newest first.
  Future<List<Review>> list(String eventId, {int? limit}) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM reviews WHERE event_id = ? '
          'ORDER BY created_at DESC, id DESC'
          '${limit == null ? '' : ' LIMIT $limit'}',
          variables: [Variable.withString(eventId)],
        )
        .get();
    return [for (final r in rows) _from(r)];
  }

  Future<Review?> mine(String eventId, String userId) async {
    final row = await db
        .customSelect(
          'SELECT * FROM reviews WHERE event_id = ? AND user_id = ?',
          variables: [
            Variable.withString(eventId),
            Variable.withString(userId),
          ],
        )
        .getSingleOrNull();
    return row == null ? null : _from(row);
  }

  Future<bool> hasValidTicket(String userId, String eventId) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM tickets WHERE user_id = ? '
          "AND event_id = ? AND status != 'cancelled'",
          variables: [
            Variable.withString(userId),
            Variable.withString(eventId),
          ],
        )
        .getSingle();
    return row.read<int>('c') > 0;
  }

  Future<ReviewEligibility> eligibility(String? userId, Event event) async {
    if (userId == null) return ReviewEligibility.signedOut;
    return ReviewRules.eligibility(
      signedIn: true,
      hasValidTicket: await hasValidTicket(userId, event.id),
      eventEnded: !_clock().isBefore(event.endAt),
      alreadyReviewed: await mine(event.id, userId) != null,
    );
  }

  // --------------------------------------------------------------- writes

  Future<Result<Review>> create({
    required String userId,
    required String authorName,
    required Event event,
    required int rating,
    required String text,
  }) async {
    if (ReviewRules.validate(rating, text) case final e?) return _fail(e);
    switch (await eligibility(userId, event)) {
      case ReviewEligibility.eligible:
        break;
      case ReviewEligibility.reviewed:
        return _fail(
          ReviewFailure(
            ReviewError.duplicate,
            AppLocale.l10n.revDupEdit,
          ),
        );
      case ReviewEligibility.notEnded:
        return _fail(
          ReviewFailure(
            ReviewError.notAllowed,
            AppLocale.l10n.revAfterEnd,
          ),
        );
      case ReviewEligibility.signedOut || ReviewEligibility.noTicket:
        return _fail(
          ReviewFailure(
            ReviewError.notAllowed,
            AppLocale.l10n.revOnlyAttendees,
          ),
        );
    }
    final now = _clock();
    final review = Review(
      id: 'r_${now.microsecondsSinceEpoch.toRadixString(36)}_${_seq++}',
      eventId: event.id,
      userId: userId,
      authorName: authorName,
      rating: rating,
      body: text.trim(),
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _insert(review);
    } on Object {
      // UNIQUE(event_id, user_id) caught a concurrent duplicate.
      return _fail(
        ReviewFailure(
          ReviewError.duplicate,
          AppLocale.l10n.revDup,
        ),
      );
    }
    return Result.success(review);
  }

  Future<Result<Review>> update({
    required String reviewId,
    required String userId,
    required int rating,
    required String text,
  }) async {
    if (ReviewRules.validate(rating, text) case final e?) return _fail(e);
    final existing = await _byId(reviewId);
    if (existing == null || existing.userId != userId) return _notFound();
    final updated = Review(
      id: existing.id,
      eventId: existing.eventId,
      userId: userId,
      authorName: existing.authorName,
      avatarUrl: existing.avatarUrl,
      rating: rating,
      body: text.trim(),
      createdAt: existing.createdAt,
      updatedAt: _clock(),
    );
    await db.customUpdate(
      'UPDATE reviews SET rating = ?, body = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withInt(rating),
        Variable.withString(updated.body),
        Variable.withInt(updated.updatedAt.millisecondsSinceEpoch),
        Variable.withString(reviewId),
      ],
      updateKind: UpdateKind.update,
    );
    return Result.success(updated);
  }

  Future<Result<void>> delete({
    required String reviewId,
    required String userId,
  }) async {
    final existing = await _byId(reviewId);
    if (existing == null || existing.userId != userId) return _notFound();
    await db.customUpdate(
      'DELETE FROM reviews WHERE id = ?',
      variables: [Variable.withString(reviewId)],
      updateKind: UpdateKind.delete,
    );
    return const Result.success(null);
  }

  // ----------------------------------------------------------------- seed

  /// Imports the catalogue's reviews once, plus a fuller set of attendee
  /// reviews for events that have already ended.
  Future<void> seedIfNeeded(List<Event> events) async {
    if (events.isEmpty || await db.readMeta(_seedKey) != null) return;
    final now = _clock();
    await db.transaction(() async {
      for (final e in events) {
        var i = 0;
        for (final r in e.reviews) {
          await _insert(
            Review(
              id: 'seed-${e.id}-$i',
              eventId: e.id,
              userId: 'seed:${e.id}:$i',
              authorName: r.author,
              avatarUrl: r.avatarUrl,
              rating: r.rating.clamp(1, 5),
              body: r.text,
              createdAt: r.date,
              updatedAt: r.date,
            ),
            orIgnore: true,
          );
          i++;
        }
        if (e.endAt.isAfter(now)) continue;
        for (final (k, (name, stars, text)) in _pastPool.indexed) {
          final at = e.endAt.add(Duration(hours: 6 + k * 9));
          await _insert(
            Review(
              id: 'seed-${e.id}-x$k',
              eventId: e.id,
              userId: 'seed:${e.id}:x$k',
              authorName: name,
              // Rotate ratings per event so histograms differ.
              rating: stars,
              body: text,
              createdAt: at,
              updatedAt: at,
            ),
            orIgnore: true,
          );
        }
      }
      await db.writeMeta(_seedKey, now.toIso8601String());
    });
  }

  static const _pastPool = <(String, int, String)>[
    ('Nadia Rahman', 5, 'Loved every minute. The venue was easy to reach.'),
    ('Chris Ortega', 4, 'Great atmosphere, the queue at the bar was long.'),
    ('Priya Nair', 5, 'Brilliant line-up and the sound was crystal clear.'),
    ('Tom Becker', 3, 'Good night overall but it started 30 minutes late.'),
    ('Lea Martin', 4, 'Friendly staff and fair prices. Would go again.'),
    ('Omar Haddad', 5, 'Best event I have been to this year, no question.'),
    ('Emily Stone', 2, 'Too crowded near the stage and hard to see much.'),
  ];

  // -------------------------------------------------------------- helpers

  Future<void> _insert(Review r, {bool orIgnore = false}) => db.customInsert(
    'INSERT ${orIgnore ? 'OR IGNORE ' : ''}INTO reviews (id, event_id, '
    'user_id, author_name, avatar_url, rating, body, created_at, updated_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    variables: [
      Variable.withString(r.id),
      Variable.withString(r.eventId),
      Variable.withString(r.userId),
      Variable.withString(r.authorName),
      Variable.withString(r.avatarUrl),
      Variable.withInt(r.rating),
      Variable.withString(r.body),
      Variable.withInt(r.createdAt.millisecondsSinceEpoch),
      Variable.withInt(r.updatedAt.millisecondsSinceEpoch),
    ],
  );

  Future<Review?> _byId(String id) async {
    final row = await db
        .customSelect(
          'SELECT * FROM reviews WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _from(row);
  }

  Review _from(QueryRow r) => Review(
    id: r.read<String>('id'),
    eventId: r.read<String>('event_id'),
    userId: r.read<String>('user_id'),
    authorName: r.read<String>('author_name'),
    avatarUrl: r.read<String>('avatar_url'),
    rating: r.read<int>('rating'),
    body: r.read<String>('body'),
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.read<int>('created_at')),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(r.read<int>('updated_at')),
  );

  Result<T> _fail<T>(ReviewFailure e) => Result.failure(e);

  Result<T> _notFound<T>() => _fail(
    ReviewFailure(ReviewError.notFound, AppLocale.l10n.revNotFound),
  );
}
