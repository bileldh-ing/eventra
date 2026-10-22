import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/pricing.dart';
import 'package:eventra/features/tickets/domain/promo.dart';
import 'package:eventra/features/tickets/presentation/booking_success_screen.dart';
import 'package:eventra/features/tickets/presentation/checkout_screen.dart';
import 'package:eventra/features/tickets/presentation/my_tickets_screen.dart';
import 'package:eventra/features/tickets/presentation/ticket_detail_screen.dart';
import 'package:eventra/features/tickets/presentation/tier_picker_screen.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticket_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../helpers/fakes.dart';
import '../../helpers/golden.dart';
import '../../helpers/harness.dart';

// Highland Music Festival: Early Bird $52 (11 left), GA $65 (49 left),
// VIP $143 (5 left), June 2027.
const highland = 'evt-001-highland-music-festival';

const gaLine = PriceLine(
  tierId: 'ga',
  tierName: 'General Admission',
  unitCents: 6500,
  quantity: 2,
);

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

Future<TestApp> openPicker(WidgetTester tester, {TestApp? app}) async {
  await setPhoneSize(tester);
  final a = app ?? TestApp();
  await tester.pumpWidget(
    a.build(initialLocation: '/home/event/$highland/tickets'),
  );
  await tester.pumpAndSettle();
  expect(find.byType(TierPickerScreen), findsOneWidget);
  return a;
}

/// Picks 2 GA tickets and continues to checkout.
Future<void> toCheckout(WidgetTester tester) async {
  await tapKey(tester, 'tier-ga-plus');
  await tapKey(tester, 'tier-ga-plus');
  await tapKey(tester, 'tier-continue');
  expect(find.byType(CheckoutScreen), findsOneWidget);
}

/// Pumps until [finder] shows (payment and DB work span several frames,
/// and the success check stays up for 900 ms).
Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pumpAndSettle();
}

Future<void> pay(WidgetTester tester) async {
  await tapKey(tester, 'pay-button');
  await pumpUntil(tester, find.byType(BookingSuccessScreen));
}

void main() {
  testWidgets('tier picker: live totals, limits, low stock and sold out', (
    tester,
  ) async {
    await openPicker(tester);
    expect(find.byKey(const ValueKey('tier-early')), findsOneWidget);
    expect(find.byKey(const ValueKey('tier-vip')), findsOneWidget);
    expect(find.text('49 of 84 left'), findsOneWidget);
    // VIP has 5 left: low stock badge.
    expect(find.byKey(const ValueKey('lowstock-vip')), findsOneWidget);
    expect(find.text('Choose your tickets to see the total.'), findsOneWidget);

    await tapKey(tester, 'tier-ga-plus');
    await tapKey(tester, 'tier-ga-plus');
    final q = priceOrder([gaLine]);
    expect(textOf(tester, 'picker-subtotal'), formatCents(13000));
    expect(textOf(tester, 'picker-total'), formatCents(q.totalCents));
    await tapKey(tester, 'tier-ga-minus');
    expect(textOf(tester, 'picker-subtotal'), formatCents(6500));

    // VIP stops at its per-order max of 4.
    for (var i = 0; i < 5; i++) {
      await tapKey(tester, 'tier-vip-plus');
    }
    expect(find.byKey(const ValueKey('tier-vip-qty-4')), findsOneWidget);
    // Order cap of 8: 1 GA + 4 VIP + 3 Early Bird.
    for (var i = 0; i < 4; i++) {
      await tapKey(tester, 'tier-early-plus');
    }
    expect(find.byKey(const ValueKey('tier-early-qty-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('order-cap')), findsOneWidget);
  });

  testWidgets('end to end: promo, pay, success, reminders, wallet, QR', (
    tester,
  ) async {
    final app = await openPicker(tester);
    await toCheckout(tester);
    expect(find.text('Tickets held for 10:00'), findsOneWidget);
    // Attendee details are prefilled from the account.
    expect(find.text('Daniel Brooks'), findsWidgets);
    expect(find.text('demo@eventra.app'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('promo-field')),
      'summer25',
    );
    await tapKey(tester, 'promo-apply');
    expect(find.text('This code has expired.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('promo-field')),
      'EVENTRA10',
    );
    await tapKey(tester, 'promo-apply');
    expect(find.byKey(const ValueKey('promo-applied')), findsOneWidget);
    final q = priceOrder([gaLine], promo: findPromo('EVENTRA10'));
    expect(textOf(tester, 'amount-discount'), formatCents(-1300));
    expect(textOf(tester, 'amount-total'), formatCents(q.totalCents));
    expect(find.text('Pay ${formatCents(q.totalCents)}'), findsOneWidget);

    await pay(tester);
    expect(find.byType(BookingSuccessScreen), findsOneWidget);
    expect(find.text("You're in!"), findsOneWidget);
    expect(app.gateway.capturedCount, 1);
    expect(app.reminders.scheduled.values.single, hasLength(2));
    expect(find.byKey(const ValueKey('reminder-note')), findsOneWidget);

    await tapKey(tester, 'success-calendar');
    expect(app.calendar.added.single.title, 'Highland Music Festival');
    await tapKey(tester, 'success-invite');
    expect(app.share.shared.single, contains('Highland Music Festival'));

    await tapKey(tester, 'view-ticket');
    expect(find.byType(MyTicketsScreen), findsOneWidget);
    expect(find.text('Upcoming (2)'), findsOneWidget);
    expect(find.byType(WalletTicketCard), findsNWidgets(2));

    await tester.tap(find.byType(WalletTicketCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(TicketDetailScreen), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Valid'), findsOneWidget);
    expect(app.brightness.boosted, isTrue);
    await tapKey(tester, 'ticketing-back');
    expect(app.brightness.boosted, isFalse);
  });

  testWidgets('double tap on Pay creates exactly one order', (tester) async {
    final app = await openPicker(tester);
    await toCheckout(tester);
    final pay = find.byKey(const ValueKey('pay-button'));
    await tester.tap(pay);
    await tester.tap(pay, warnIfMissed: false);
    await pumpUntil(tester, find.byType(BookingSuccessScreen));
    expect(find.byType(BookingSuccessScreen), findsOneWidget);
    expect(app.gateway.capturedCount, 1);
    expect(app.reminders.scheduled, hasLength(1));
  });

  testWidgets('declined new card shows retry; a saved card then succeeds', (
    tester,
  ) async {
    final app = await openPicker(tester);
    await toCheckout(tester);
    await tapKey(tester, 'add-card');
    expect(find.byKey(const ValueKey('card-sheet')), findsOneWidget);
    // Invalid Luhn first.
    await tester.enterText(
      find.byKey(const ValueKey('card-number')),
      '4242424242424241',
    );
    await tester.enterText(find.byKey(const ValueKey('card-expiry')), '1229');
    await tester.enterText(find.byKey(const ValueKey('card-cvc')), '123');
    await tester.enterText(find.byKey(const ValueKey('card-name')), 'Daniel');
    await tapKey(tester, 'card-save');
    expect(find.text('That card number is not valid.'), findsOneWidget);
    expect(find.text('12/29'), findsOneWidget); // expiry formatter
    await tester.enterText(
      find.byKey(const ValueKey('card-number')),
      '4000000000000002',
    );
    expect(find.text('4000 0000 0000 0002'), findsOneWidget);
    await tapKey(tester, 'card-save');
    expect(find.byKey(const ValueKey('card-sheet')), findsNothing);
    expect(find.byKey(const ValueKey('method-new')), findsOneWidget);

    await tapKey(tester, 'pay-button');
    expect(find.byKey(const ValueKey('checkout-error')), findsOneWidget);
    expect(
      find.text('Your card was declined. Try another card.'),
      findsOneWidget,
    );
    expect(app.gateway.capturedCount, 0);
    expect(find.byType(CheckoutScreen), findsOneWidget);

    await tapKey(tester, 'method-card_visa');
    await pay(tester);
    expect(find.byType(BookingSuccessScreen), findsOneWidget);
    expect(app.gateway.capturedCount, 1);
  });

  testWidgets('3-D Secure sheet: cancel keeps you on checkout, approve pays', (
    tester,
  ) async {
    final app = await openPicker(tester);
    await toCheckout(tester);
    await tapKey(tester, 'method-card_mc');
    await tapKey(tester, 'pay-button');
    expect(find.byKey(const ValueKey('three-ds-sheet')), findsOneWidget);
    await tapKey(tester, 'three-ds-cancel');
    expect(
      find.text('Card authentication was cancelled. You were not charged.'),
      findsOneWidget,
    );
    await tapKey(tester, 'pay-button');
    await tapKey(tester, 'three-ds-approve');
    await pumpUntil(tester, find.byType(BookingSuccessScreen));
    expect(find.byType(BookingSuccessScreen), findsOneWidget);
    expect(app.gateway.capturedCount, 1);
  });

  testWidgets('hold countdown expires: pay disabled, choose again', (
    tester,
  ) async {
    final clock = TestClock(kTestNow);
    await openPicker(tester, app: TestApp(clock: clock.call));
    await toCheckout(tester);
    clock.advance(const Duration(minutes: 8, seconds: 30));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Tickets held for 01:30'), findsOneWidget);
    clock.advance(const Duration(minutes: 2));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(
      find.text('Your hold expired and the tickets were released.'),
      findsOneWidget,
    );
    await tapKey(tester, 'pay-button');
    expect(find.byType(CheckoutScreen), findsOneWidget);
    await tapKey(tester, 'hold-restart');
    expect(find.byType(TierPickerScreen), findsOneWidget);
    expect(find.text('49 of 84 left'), findsOneWidget);
  });

  testWidgets('leaving checkout asks, then releases the seats', (
    tester,
  ) async {
    await openPicker(tester);
    await toCheckout(tester);
    await tapKey(tester, 'ticketing-back');
    expect(find.text('Leave checkout?'), findsOneWidget);
    await tapKey(tester, 'stay-checkout');
    expect(find.byType(CheckoutScreen), findsOneWidget);
    await tapKey(tester, 'ticketing-back');
    await tapKey(tester, 'release-hold');
    expect(find.byType(TierPickerScreen), findsOneWidget);
    expect(find.text('49 of 84 left'), findsOneWidget);
  });

  testWidgets('attendee details are validated before paying', (tester) async {
    final app = await openPicker(tester);
    await toCheckout(tester);
    await tester.enterText(
      find.byKey(const ValueKey('attendee-email')),
      'nope',
    );
    await tapKey(tester, 'pay-button');
    expect(find.text('Enter a valid email.'), findsOneWidget);
    expect(app.gateway.capturedCount, 0);
  });

  testWidgets('checkout golden', (tester) async {
    await withRealShadows(() async {
      await setPhoneSize(tester, dpr: 2);
      await tester.pumpWidget(
        TestApp().build(initialLocation: '/home/event/$highland/tickets'),
      );
      await tester.pumpAndSettle();
      await toCheckout(tester);
      await tester.enterText(
        find.byKey(const ValueKey('promo-field')),
        'EVENTRA10',
      );
      await tapKey(tester, 'promo-apply');
      await tester.drag(
        find.byKey(const ValueKey('checkout-scroll')),
        const Offset(0, 600),
      );
      await tester.pumpAndSettle();
      await precacheVisibleImages(tester);
      await tester.pumpAndSettle();
      await expectGolden(find.byType(CheckoutScreen), 'goldens/checkout.png');
    });
  }, tags: ['golden']);
}
