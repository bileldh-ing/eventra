import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/notifications/data/notifications_repository.dart';
import 'package:eventra/features/notifications/domain/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

void main() {
  late AppDatabase db;
  late NotificationsRepository repo;
  var now = DateTime(2026, 10, 21, 10);
  final events = loadSeed().events;

  setUp(() {
    now = DateTime(2026, 10, 21, 10);
    db = memoryDb();
    repo = NotificationsRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('seeds a welcome inbox once per scope, newest first', () async {
    expect(await repo.seedIfNeeded('u1', events), isTrue);
    expect(await repo.seedIfNeeded('u1', events), isFalse);
    final items = await repo.list('u1');
    expect(items, hasLength(5));
    expect(items.where((n) => !n.read), hasLength(2));
    for (var i = 1; i < items.length; i++) {
      expect(items[i - 1].time.isAfter(items[i].time), isTrue);
    }
    // The review prompt points at a finished event.
    final prompt = items.firstWhere(
      (n) => n.kind == NotificationKind.reviewPrompt,
    );
    final e = events.firstWhere((x) => x.id == prompt.eventId);
    expect(e.endAt.isBefore(now), isTrue);
    // Clearing the inbox does not re-seed it.
    await repo.clear('u1');
    expect(await repo.seedIfNeeded('u1', events), isFalse);
    expect(await repo.list('u1'), isEmpty);
  });

  test('scopes are isolated', () async {
    await repo.seedIfNeeded('u1', events);
    await repo.add(
      'u2',
      kind: NotificationKind.orderConfirmed,
      title: 'Booking confirmed',
      body: '2 tickets',
      eventId: 'e1',
      ticketId: 't1',
    );
    expect(await repo.list('u2'), hasLength(1));
    expect(await repo.list('u1'), hasLength(5));
    await repo.markAllRead('u2');
    expect((await repo.list('u1')).where((n) => !n.read), hasLength(2));
  });

  test('add, mark read, mark all read', () async {
    final a = await repo.add(
      'u1',
      kind: NotificationKind.orderConfirmed,
      title: 'Booking confirmed',
      body: 'Tickets ready',
      eventId: 'e1',
      ticketId: 't1',
    );
    now = now.add(const Duration(minutes: 1));
    await repo.add(
      'u1',
      kind: NotificationKind.refund,
      title: 'Refund issued',
      body: r'$65.00',
      eventId: 'e1',
    );
    var items = await repo.list('u1');
    expect(items.map((n) => n.title), ['Refund issued', 'Booking confirmed']);
    expect(items.last.ticketId, 't1');
    expect(items.first.ticketId, isNull);

    await repo.markRead('u1', a.id);
    items = await repo.list('u1');
    expect(items.firstWhere((n) => n.id == a.id).read, isTrue);
    expect(items.where((n) => !n.read), hasLength(1));

    await repo.markAllRead('u1');
    expect((await repo.list('u1')).every((n) => n.read), isTrue);
  });

  test('remove and restore (undo) keep the original item', () async {
    final n = await repo.add(
      'u1',
      kind: NotificationKind.newEvent,
      title: 'New in Music',
      body: 'Just announced',
      eventId: 'e9',
    );
    await repo.remove('u1', n.id);
    expect(await repo.list('u1'), isEmpty);
    await repo.put('u1', n);
    expect(await repo.list('u1'), [n]);
  });

  test('unknown kinds fall back safely', () {
    expect(NotificationKind.parse('nope'), NotificationKind.newEvent);
    expect(NotificationKind.parse('refund'), NotificationKind.refund);
    expect(NotificationKind.priceDrop.recommendation, isTrue);
    expect(NotificationKind.orderConfirmed.recommendation, isFalse);
  });
}
