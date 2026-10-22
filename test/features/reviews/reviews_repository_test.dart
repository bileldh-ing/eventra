import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/reviews/data/reviews_repository.dart';
import 'package:eventra/features/reviews/domain/review.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

void main() {
  late AppDatabase db;
  late ReviewsRepository repo;
  late TicketingRepository tickets;
  final now = DateTime(2026, 10, 21, 10);
  final events = loadSeed().events;
  final past = events.firstWhere((e) => e.id == 'evt-p04-late-laughs-showcase');
  final upcoming = events.firstWhere(
    (e) => e.id == 'evt-001-highland-music-festival',
  );
  const text = 'Great night, the host was hilarious.';

  setUp(() {
    db = memoryDb();
    repo = ReviewsRepository(db, clock: () => now);
    tickets = TicketingRepository(
      db: db,
      gateway: MockPaymentGateway(latency: Duration.zero),
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  Future<void> giveTicket(String user, Event e) => tickets.ensureDemoPastOrder(
    userId: user,
    attendeeName: 'Daniel Brooks',
    attendeeEmail: 'demo@eventra.app',
    event: e,
  );

  Future<Result<Review>> write(
    String user,
    Event e, {
    int rating = 4,
    String body = text,
  }) => repo.create(
    userId: user,
    authorName: 'Daniel Brooks',
    event: e,
    rating: rating,
    text: body,
  );

  ReviewError? errorOf(Result<Object?> r) => switch (r) {
    Failure(failure: ReviewFailure(:final code)) => code,
    _ => null,
  };

  test('users without a ticket cannot review', () async {
    expect(await repo.eligibility('u1', past), ReviewEligibility.noTicket);
    expect(await repo.eligibility(null, past), ReviewEligibility.signedOut);
    expect(errorOf(await write('u1', past)), ReviewError.notAllowed);
  });

  test('ticket holders review only after the event ends', () async {
    await giveTicket('u1', upcoming);
    expect(await repo.eligibility('u1', upcoming), ReviewEligibility.notEnded);
    expect(errorOf(await write('u1', upcoming)), ReviewError.notAllowed);
  });

  test('cancelled tickets do not count', () async {
    await giveTicket('u1', past);
    await db.customStatement(
      "UPDATE tickets SET status = 'cancelled' WHERE user_id = 'u1'",
    );
    expect(await repo.eligibility('u1', past), ReviewEligibility.noTicket);
  });

  test('a past ticket holder reviews once, then edits or deletes', () async {
    await giveTicket('u1', past);
    expect(await repo.eligibility('u1', past), ReviewEligibility.eligible);

    final created = (await write('u1', past, rating: 5)).valueOrNull!;
    expect(created.body, text);
    expect(await repo.eligibility('u1', past), ReviewEligibility.reviewed);
    expect(errorOf(await write('u1', past)), ReviewError.duplicate);

    final edited = await repo.update(
      reviewId: created.id,
      userId: 'u1',
      rating: 3,
      text: 'Fun, but the second half dragged on.',
    );
    expect(edited.valueOrNull!.rating, 3);
    expect((await repo.mine(past.id, 'u1'))!.rating, 3);

    // Someone else cannot touch it.
    final hijack = await repo.update(
      reviewId: created.id,
      userId: 'u2',
      rating: 1,
      text: 'Not my review at all.',
    );
    expect(errorOf(hijack), ReviewError.notFound);
    expect(
      errorOf(await repo.delete(reviewId: created.id, userId: 'u2')),
      ReviewError.notFound,
    );

    expect(
      (await repo.delete(reviewId: created.id, userId: 'u1')).isSuccess,
      isTrue,
    );
    expect(await repo.mine(past.id, 'u1'), isNull);
    expect(await repo.eligibility('u1', past), ReviewEligibility.eligible);
  });

  test('validation runs on create and update', () async {
    await giveTicket('u1', past);
    expect(errorOf(await write('u1', past, body: 'meh')), ReviewError.tooShort);
    expect(
      errorOf(await write('u1', past, body: 'x' * 501)),
      ReviewError.tooLong,
    );
    expect(
      errorOf(await write('u1', past, rating: 0)),
      ReviewError.invalidRating,
    );
    final r = (await write('u1', past)).valueOrNull!;
    final bad = await repo.update(
      reviewId: r.id,
      userId: 'u1',
      rating: 6,
      text: text,
    );
    expect(errorOf(bad), ReviewError.invalidRating);
  });

  test('the database enforces one review per user per event', () async {
    await giveTicket('u1', past);
    await write('u1', past);
    expect(
      () => db.customStatement(
        'INSERT INTO reviews (id, event_id, user_id, author_name, rating, '
        "body, created_at, updated_at) VALUES ('dup', ?, 'u1', 'x', 4, "
        "'another one', 0, 0)",
        [past.id],
      ),
      throwsA(anything),
    );
  });

  test(
    'seeding imports catalogue reviews once, more for past events',
    () async {
      await repo.seedIfNeeded(events);
      await repo.seedIfNeeded(events);
      final up = await repo.summary(upcoming.id);
      expect(up.count, upcoming.reviews.length);
      final p = await repo.summary(past.id);
      expect(p.count, past.reviews.length + 7);
      expect(p.histogram.reduce((a, b) => a + b), p.count);
      expect(p.average, inInclusiveRange(1, 5));
      final latest = await repo.list(past.id, limit: 3);
      expect(latest, hasLength(3));
      expect(
        latest.first.createdAt.isAfter(latest.last.createdAt) ||
            latest.first.createdAt == latest.last.createdAt,
        isTrue,
      );
      final count = await db
          .customSelect('SELECT COUNT(*) AS c FROM reviews')
          .getSingle();
      expect(count.read<int>('c'), greaterThan(events.length * 3));
    },
  );

  test('summary updates after a new review', () async {
    await repo.seedIfNeeded(events);
    final before = await repo.summary(past.id);
    await giveTicket('u1', past);
    await write('u1', past, rating: 1);
    final after = await repo.summary(past.id);
    expect(after.count, before.count + 1);
    expect(after.histogram[0], before.histogram[0] + 1);
  });
}
