import 'package:drift/drift.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/notifications/domain/app_notification.dart';
import 'package:eventra/l10n/l10n.dart';

/// Persistent notification inbox, one per scope (user id or 'guest').
class NotificationsRepository {
  NotificationsRepository(this.db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final DateTime Function() _clock;
  var _seq = 0;

  String _newId() =>
      'n_${_clock().microsecondsSinceEpoch.toRadixString(36)}_${_seq++}';

  /// Newest first.
  Future<List<AppNotification>> list(String scope) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM notifications WHERE scope = ? '
          'ORDER BY created_at DESC, id DESC',
          variables: [Variable.withString(scope)],
        )
        .get();
    return [for (final r in rows) _from(r)];
  }

  Future<AppNotification> add(
    String scope, {
    required NotificationKind kind,
    required String title,
    required String body,
    String? eventId,
    String? ticketId,
    DateTime? time,
    bool read = false,
  }) async {
    final n = AppNotification(
      id: _newId(),
      kind: kind,
      title: title,
      body: body,
      time: time ?? _clock(),
      eventId: eventId,
      ticketId: ticketId,
      read: read,
    );
    await put(scope, n);
    return n;
  }

  /// Inserts or replaces [n] (also used to undo a dismiss).
  Future<void> put(String scope, AppNotification n) => db.customInsert(
    'INSERT OR REPLACE INTO notifications (id, scope, kind, title, body, '
    'event_id, ticket_id, created_at, read) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    variables: [
      Variable.withString(n.id),
      Variable.withString(scope),
      Variable.withString(n.kind.name),
      Variable.withString(n.title),
      Variable.withString(n.body),
      Variable<String>(n.eventId),
      Variable<String>(n.ticketId),
      Variable.withInt(n.time.millisecondsSinceEpoch),
      Variable.withInt(n.read ? 1 : 0),
    ],
  );

  Future<void> markRead(String scope, String id) => db.customUpdate(
    'UPDATE notifications SET read = 1 WHERE scope = ? AND id = ?',
    variables: [Variable.withString(scope), Variable.withString(id)],
    updateKind: UpdateKind.update,
  );

  Future<void> markAllRead(String scope) => db.customUpdate(
    'UPDATE notifications SET read = 1 WHERE scope = ?',
    variables: [Variable.withString(scope)],
    updateKind: UpdateKind.update,
  );

  Future<void> remove(String scope, String id) => db.customUpdate(
    'DELETE FROM notifications WHERE scope = ? AND id = ?',
    variables: [Variable.withString(scope), Variable.withString(id)],
    updateKind: UpdateKind.delete,
  );

  Future<void> clear(String scope) => db.customUpdate(
    'DELETE FROM notifications WHERE scope = ?',
    variables: [Variable.withString(scope)],
    updateKind: UpdateKind.delete,
  );

  /// Fills a new inbox with a welcome set built from the catalogue, once
  /// per scope. Returns whether anything was inserted.
  Future<bool> seedIfNeeded(String scope, List<Event> events) async {
    final key = 'notifications_seeded:$scope';
    if (await db.readMeta(key) != null || events.isEmpty) return false;
    final now = _clock();
    final upcoming = events.where((e) => e.startAt.isAfter(now)).toList();
    final past = events.where((e) => !e.endAt.isAfter(now)).toList()
      ..sort((a, b) => b.endAt.compareTo(a.endAt));
    if (upcoming.isEmpty) return false;
    Event pick(int i) => upcoming[i % upcoming.length];
    final music = upcoming.where((e) => e.title == 'Pitchfork Music Night');
    final pitchfork = music.isEmpty ? pick(0) : music.first;
    final seeds = <AppNotification>[
      AppNotification(
        id: 'seed-friends-$scope',
        kind: NotificationKind.friendGoing,
        title: AppLocale.l10n.seedFriendsTitle,
        body: AppLocale.l10n.seedFriendsBody(pitchfork.title),
        time: now.subtract(const Duration(minutes: 25)),
        eventId: pitchfork.id,
      ),
      AppNotification(
        id: 'seed-soon-$scope',
        kind: NotificationKind.reminder,
        title: AppLocale.l10n.seedSoonTitle,
        body: AppLocale.l10n.seedSoonBody(pick(0).title),
        time: now.subtract(const Duration(hours: 3)),
        eventId: pick(0).id,
      ),
      if (past.isNotEmpty)
        AppNotification(
          id: 'seed-review-$scope',
          kind: NotificationKind.reviewPrompt,
          title: AppLocale.l10n.seedReviewTitle(past.first.title),
          body: AppLocale.l10n.seedReviewBody,
          time: now.subtract(const Duration(days: 1)),
          eventId: past.first.id,
          read: true,
        ),
      AppNotification(
        id: 'seed-new-$scope',
        kind: NotificationKind.newEvent,
        title: AppLocale.l10n.seedNewTitle,
        body: AppLocale.l10n.seedNewBody(pick(5).title),
        time: now.subtract(const Duration(days: 1, hours: 2)),
        eventId: pick(5).id,
        read: true,
      ),
      AppNotification(
        id: 'seed-price-$scope',
        kind: NotificationKind.priceDrop,
        title: AppLocale.l10n.seedPriceTitle,
        body: AppLocale.l10n.seedPriceBody(pick(9).title),
        time: now.subtract(const Duration(days: 2)),
        eventId: pick(9).id,
        read: true,
      ),
    ];
    await db.transaction(() async {
      for (final n in seeds) {
        await put(scope, n);
      }
      await db.writeMeta(key, now.toIso8601String());
    });
    return true;
  }

  AppNotification _from(QueryRow r) => AppNotification(
    id: r.read<String>('id'),
    kind: NotificationKind.parse(r.read<String>('kind')),
    title: r.read<String>('title'),
    body: r.read<String>('body'),
    time: DateTime.fromMillisecondsSinceEpoch(r.read<int>('created_at')),
    eventId: r.readNullable<String>('event_id'),
    ticketId: r.readNullable<String>('ticket_id'),
    read: r.read<int>('read') == 1,
  );
}
