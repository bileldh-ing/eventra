import 'package:eventra/features/event_details/presentation/event_details_screen.dart';
import 'package:eventra/features/notifications/presentation/notifications_providers.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/features/tickets/presentation/ticket_detail_screen.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

void main() {
  Future<ProviderContainer> pumpInbox(WidgetTester tester) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      TestApp().build(initialLocation: '/home/notifications'),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  testWidgets('swipe dismiss persists; undo restores', (tester) async {
    final c = await pumpInbox(tester);
    expect(find.text('2 friends are going'), findsOneWidget);
    await tester.drag(find.text('2 friends are going'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 friends are going'), findsNothing);
    var stored = await tester.runAsync(
      () => c.read(notificationsRepositoryProvider).list('u_demo'),
    );
    expect(stored!.any((n) => n.title == '2 friends are going'), isFalse);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('2 friends are going'), findsOneWidget);
    stored = await tester.runAsync(
      () => c.read(notificationsRepositoryProvider).list('u_demo'),
    );
    expect(stored!.any((n) => n.title == '2 friends are going'), isTrue);
  });

  testWidgets('tapping an event item opens the event and marks it read', (
    tester,
  ) async {
    final c = await pumpInbox(tester);
    expect(c.read(unreadCountProvider), 2);
    await tester.tap(find.text('Coming up soon'));
    await tester.pumpAndSettle();
    expect(find.byType(EventDetailsScreen), findsOneWidget);
    expect(c.read(unreadCountProvider), 1);
  });

  testWidgets('a purchase adds a confirmation that opens the ticket', (
    tester,
  ) async {
    final c = await pumpInbox(tester);
    final event = loadSeed().events.firstWhere(
      (e) => e.id == 'evt-001-highland-music-festival',
    );
    await tester.runAsync(() async {
      final actions = c.read(ticketingActionsProvider);
      final hold = (await actions.hold(
        userId: 'u_demo',
        event: event,
        quantities: {'ga': 1},
      )).valueOrNull!;
      await actions.pay(
        CheckoutRequest(
          holdId: hold.id,
          userId: 'u_demo',
          event: event,
          attendeeName: 'Daniel Brooks',
          attendeeEmail: 'demo@eventra.app',
          idempotencyKey: 'k1',
          method: SavedCardMethod(kDemoCards.first),
        ),
      );
    });
    await tester.pumpAndSettle();
    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(c.read(unreadCountProvider), 3);
    await tester.tap(find.text('Booking confirmed'));
    await tester.pumpAndSettle();
    expect(find.byType(TicketDetailScreen), findsOneWidget);
  });
}
