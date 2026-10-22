import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/login_screen.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/features/tickets/domain/qr_token.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/my_tickets_screen.dart';
import 'package:eventra/features/tickets/presentation/ticket_detail_screen.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticket_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../helpers/fakes.dart';
import '../../helpers/golden.dart';
import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

final List<Event> _events = loadSeed().events;
Event _event(String id) => _events.firstWhere((e) => e.id == id);

/// Books [qty] GA tickets for the demo user straight through the repository.
Future<Order> book(
  TicketingRepository repo,
  Event event, {
  int qty = 1,
  String tier = 'ga',
  String key = 'k',
}) async {
  final hold = (await repo.createHold(
    userId: kTestUser.id,
    event: event,
    quantities: {tier: qty},
  )).valueOrNull!;
  return (await repo.placeOrder(
    CheckoutRequest(
      holdId: hold.id,
      userId: kTestUser.id,
      event: event,
      attendeeName: kTestUser.name,
      attendeeEmail: kTestUser.email,
      idempotencyKey: key,
      method: SavedCardMethod(kDemoCards.first),
    ),
  )).valueOrNull!;
}

void main() {
  late TestApp app;
  late TicketingRepository repo;

  // Upcoming (Jun 2027), past (moved to Sep 2026) and refunded orders.
  final upcoming = _event('evt-001-highland-music-festival');
  final past = _event('evt-002-pitchfork-music-night').copyWith(
    startAt: DateTime(2026, 9, 12, 20),
    endAt: DateTime(2026, 9, 12, 23),
  );
  final refunded = _event('evt-003-national-music-festival');

  Future<void> seed() async {
    final db = memoryDb();
    addTearDown(db.close);
    app = TestApp(db: db);
    final ids = SequentialIds();
    repo = TicketingRepository(
      db: db,
      gateway: MockPaymentGateway(latency: Duration.zero),
      clock: () => kTestNow,
      ids: ids.next,
    );
    await book(repo, upcoming, qty: 2, key: 'a');
    await book(repo, past, key: 'b');
    final r = await book(repo, refunded, key: 'c');
    await repo.refundOrder(r.id, userId: kTestUser.id);
  }

  testWidgets('wallet tabs: Upcoming / Past / Cancelled with swipe', (
    tester,
  ) async {
    await tester.runAsync(seed);
    await setPhoneSize(tester);
    await tester.pumpWidget(app.build(initialLocation: '/tickets'));
    await tester.pumpAndSettle();
    expect(find.byType(MyTicketsScreen), findsOneWidget);
    expect(find.text('Upcoming (2)'), findsOneWidget);
    expect(find.text('Past (1)'), findsOneWidget);
    expect(find.text('Cancelled (1)'), findsOneWidget);
    expect(find.byType(WalletTicketCard), findsNWidgets(2));
    expect(find.textContaining('Ticket 2 of 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-past')));
    await tester.pumpAndSettle();
    expect(find.text('Pitchfork Music Night'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);

    // Swipe left to Cancelled.
    await tester.fling(
      find.byKey(const ValueKey('list-past')),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Cancelled'), findsWidgets);
    expect(find.text('National Music Festival'), findsOneWidget);
  });

  testWidgets('empty wallet offers Explore events', (tester) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(TestApp().build(initialLocation: '/tickets'));
    await tester.pumpAndSettle();
    expect(find.text('No upcoming tickets'), findsOneWidget);
    await tester.tap(find.text('Explore events'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('nav-Home')), findsOneWidget);
    expect(find.byType(MyTicketsScreen), findsNothing);
  });

  testWidgets('guests are sent to log in and come back to the wallet', (
    tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      TestApp(auth: const AuthState.guest()).build(initialLocation: '/tickets'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('ticket detail: QR rotates every 30 s and verifies', (
    tester,
  ) async {
    await tester.runAsync(seed);
    final clock = TestClock(kTestNow);
    final rotating = TestApp(db: app.db, clock: clock.call);
    final ticket = (await tester.runAsync(
      () => repo.ticketsFor(kTestUser.id),
    ))!.firstWhere((e) => e.event.id == upcoming.id);
    await setPhoneSize(tester);
    await tester.pumpWidget(
      rotating.build(initialLocation: '/tickets/${ticket.ticket.id}'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TicketDetailScreen), findsOneWidget);
    expect(rotating.brightness.boosted, isTrue);
    String payload() {
      final key = tester.widget<QrImageView>(find.byType(QrImageView)).key!;
      return (key as ValueKey<String>).value.substring(3); // 'qr-<payload>'
    }

    final first = payload();
    final qr = QrTokenService(
      List<int>.generate(32, (i) => i), // the harness key
    );
    expect(qr.verify(first, now: clock.now).isValid, isTrue);
    expect(qr.verify(first, now: clock.now).ticketId, ticket.ticket.id);
    expect(find.text('Code refreshes in 30s'), findsOneWidget);

    clock.advance(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));
    expect(payload(), first);
    expect(find.text('Code refreshes in 20s'), findsOneWidget);

    clock.advance(const Duration(seconds: 20));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final second = payload();
    expect(second, isNot(first));
    // The old code is still accepted for one window, then rejected.
    expect(qr.verify(first, now: clock.now).isValid, isTrue);
    expect(
      qr.verify(first, now: clock.now.add(const Duration(seconds: 30))).status,
      QrStatus.expired,
    );
  });

  testWidgets('ticket detail: calendar, share and refund restores stock', (
    tester,
  ) async {
    await tester.runAsync(seed);
    final entry = (await tester.runAsync(
      () => repo.ticketsFor(kTestUser.id),
    ))!.firstWhere((e) => e.event.id == upcoming.id);
    await setPhoneSize(tester);
    await tester.pumpWidget(
      app.build(initialLocation: '/tickets/${entry.ticket.id}'),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('ticket-calendar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ticket-calendar')));
    await tester.pumpAndSettle();
    expect(app.calendar.added.single.start, upcoming.startAt);
    expect(find.text('Added to your calendar'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ticket-share')));
    await tester.pumpAndSettle();
    expect(app.share.shared.single, contains(upcoming.title));

    final refund = find.byKey(const ValueKey('request-refund'));
    await tester.scrollUntilVisible(
      refund,
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('ticket-detail-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(refund);
    await tester.pumpAndSettle();
    expect(find.text('Request a refund?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-refund')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Refunded'), findsWidgets);
    expect(find.byKey(const ValueKey('qr-unavailable')), findsOneWidget);
    expect(app.reminders.cancelled, [entry.order.id]);
    final ga = (await tester.runAsync(
      () => repo.availability(upcoming),
    ))!.firstWhere((a) => a.tierId == 'ga');
    expect(ga.sold, 35); // back to the seed's sold count
  });

  testWidgets('ticket detail golden', (tester) async {
    await withRealShadows(() async {
      await tester.runAsync(seed);
      final entry = (await tester.runAsync(
        () => repo.ticketsFor(kTestUser.id),
      ))!.firstWhere((e) => e.event.id == upcoming.id);
      await setPhoneSize(tester, dpr: 2);
      await tester.pumpWidget(
        app.build(initialLocation: '/tickets/${entry.ticket.id}'),
      );
      await tester.pumpAndSettle();
      await precacheVisibleImages(tester);
      await tester.pumpAndSettle();
      await expectGolden(
        find.byType(TicketDetailScreen),
        'goldens/ticket_detail.png',
      );
    });
  }, tags: ['golden']);
}
