import 'package:drift/drift.dart' show Variable;
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/live_event_stats.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/features/tickets/domain/refund_policy.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

final List<Event> _events = loadSeed().events;
Event _event(String id) => _events.firstWhere((e) => e.id == id);

const _highland = 'evt-001-highland-music-festival';

TicketingRepository _repo(AppDatabase db, {DateTime Function()? clock}) =>
    TicketingRepository(
      db: db,
      gateway: MockPaymentGateway(latency: Duration.zero),
      clock: clock ?? () => kTestNow,
      ids: SequentialIds().next,
    );

/// Leaves exactly [left] seats across the event's tiers (fills tiers in
/// order), as other buyers would.
Future<void> _leave(AppDatabase db, Event e, int left) async {
  await _repo(db).availability(e);
  var remaining = left;
  for (final t in e.tiers) {
    final keep = remaining.clamp(0, t.capacity);
    remaining -= keep;
    await db.customUpdate(
      'UPDATE tier_stock SET sold = capacity - ? '
      'WHERE event_id = ? AND tier_id = ?',
      variables: [
        Variable.withInt(keep),
        Variable.withString(e.id),
        Variable.withString(t.id),
      ],
    );
  }
}

Future<void> _review(AppDatabase db, String eventId, String user, int stars) =>
    db.customInsert(
      'INSERT INTO reviews (id, event_id, user_id, author_name, rating, body, '
      'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, 0, 0)',
      variables: [
        Variable.withString('r-$eventId-$user'),
        Variable.withString(eventId),
        Variable.withString(user),
        Variable.withString(user),
        Variable.withInt(stars),
        Variable.withString('Good night out with friends.'),
      ],
    );

void main() {
  group('LiveEventStats', () {
    late AppDatabase db;
    setUp(() => db = memoryDb());
    tearDown(() => db.close());

    test('falls back to the catalogue when nothing is stored', () async {
      final e = _event(_highland);
      final s = await LiveEventStats.read(db, now: kTestNow);
      final stock = s.stockFor(e);
      expect(stock.left, EventStock.fromSeed(e).left);
      expect(stock.soldOut, isFalse);
      final r = s.ratingFor(e);
      expect(r.average, e.rating);
      expect(r.count, e.reviewCount);
      expect(LiveEventStats.empty.stockFor(e).left, stock.left);
    });

    test('purchases and running holds reduce stock; expired holds do not', () async {
      final e = _event(_highland);
      final seedLeft = EventStock.fromSeed(e).left;
      final repo = _repo(db);
      final hold = (await repo.createHold(
        userId: kTestUser.id,
        event: e,
        quantities: {'ga': 3},
      )).valueOrNull!;
      var s = await LiveEventStats.read(db, now: kTestNow);
      expect(s.stockFor(e).left, seedLeft - 3, reason: 'active hold');
      final later = kTestNow.add(const Duration(minutes: 11));
      s = await LiveEventStats.read(db, now: later);
      expect(s.stockFor(e).left, seedLeft, reason: 'hold expired');

      await repo.placeOrder(
        CheckoutRequest(
          holdId: hold.id,
          userId: kTestUser.id,
          event: e,
          attendeeName: kTestUser.name,
          attendeeEmail: kTestUser.email,
          idempotencyKey: 'live-1',
          method: SavedCardMethod(kDemoCards.first),
        ),
      );
      s = await LiveEventStats.read(db, now: later);
      expect(s.stockFor(e).left, seedLeft - 3, reason: 'sold');
    });

    test('low stock and sold out thresholds', () async {
      final e = _event(_highland);
      await _leave(db, e, 7);
      var stock = (await LiveEventStats.read(db, now: kTestNow)).stockFor(e);
      expect(stock.left, 7);
      expect(stock.lowStock, isTrue);
      expect(stock.soldOut, isFalse);
      await _leave(db, e, 0);
      stock = (await LiveEventStats.read(db, now: kTestNow)).stockFor(e);
      expect(stock.soldOut, isTrue);
      expect(stock.lowStock, isFalse);
      expect(const EventStock(left: 11, capacity: 20).lowStock, isFalse);
    });

    test('live review average replaces the catalogue aggregate', () async {
      final e = _event(_highland);
      await _review(db, e.id, 'a', 5);
      await _review(db, e.id, 'b', 2);
      final r = (await LiveEventStats.read(db, now: kTestNow)).ratingFor(e);
      expect(r.count, 2);
      expect(r.average, 3.5);
    });
  });

  group('screens read live numbers', () {
    Future<void> pump(WidgetTester tester, TestApp app, String location) async {
      await setPhoneSize(tester);
      await tester.pumpWidget(app.build(initialLocation: location));
      await tester.pumpAndSettle();
    }

    testWidgets('sold out after the last ticket: details CTA and Home card', (
      tester,
    ) async {
      final db = memoryDb();
      addTearDown(db.close);
      await tester.runAsync(() => _leave(db, _event(_highland), 0));
      final app = TestApp(db: db);
      await pump(tester, app, '/home/event/$_highland');
      expect(find.byKey(const ValueKey('join-waitlist')), findsOneWidget);
      expect(find.byKey(const ValueKey('get-ticket')), findsNothing);
      expect(find.byKey(const ValueKey('stock-$_highland')), findsOneWidget);

      await pump(tester, TestApp(db: db), '/home');
      expect(find.byKey(const ValueKey('stock-$_highland')), findsWidgets);
    });

    testWidgets('low stock shows "Only N left" on details and the map sheet', (
      tester,
    ) async {
      final db = memoryDb();
      addTearDown(db.close);
      await tester.runAsync(() => _leave(db, _event(_highland), 4));
      await pump(tester, TestApp(db: db), '/home/event/$_highland');
      expect(find.byKey(const ValueKey('details-low-stock')), findsOneWidget);
      expect(find.text('Only 4 left'), findsWidgets);
      expect(find.byKey(const ValueKey('get-ticket')), findsOneWidget);
    });

    testWidgets('policy card states the enforced refund rule', (tester) async {
      await pump(tester, TestApp(), '/home/event/$_highland');
      await tester.scrollUntilVisible(
        find.text(RefundPolicy.summary),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(RefundPolicy.summary), findsOneWidget);
      expect(find.textContaining('7 days'), findsNothing);
      expect(find.textContaining('50%'), findsNothing);
    });

    testWidgets('details shows the live review average', (tester) async {
      final db = memoryDb();
      addTearDown(db.close);
      final app = TestApp(db: db);
      await pump(tester, app, '/home/event/$_highland');
      final label = find.byKey(const ValueKey('rating-$_highland'));
      expect(label, findsOneWidget);
      final stats = (await tester.runAsync(
        () => LiveEventStats.read(db, now: kTestNow),
      ))!;
      final r = stats.ratingFor(_event(_highland));
      expect(r.count, _event(_highland).reviews.length);
      expect(
        find.descendant(of: label, matching: find.textContaining('(${r.count})')),
        findsOneWidget,
      );
    });
  });
}
