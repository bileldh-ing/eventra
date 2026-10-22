import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/pricing.dart';
import 'package:eventra/features/tickets/domain/promo.dart';
import 'package:eventra/features/tickets/domain/tier_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const ga = PriceLine(
  tierId: 'ga',
  tierName: 'General Admission',
  unitCents: 6500,
  quantity: 2,
);
const vip = PriceLine(
  tierId: 'vip',
  tierName: 'VIP',
  unitCents: 14300,
  quantity: 1,
);

void main() {
  final now = DateTime(2026, 10, 21, 10);

  group('money', () {
    test('cents conversion and half-up rounding', () {
      expect(toCents(52), 5200);
      expect(toCents(12.5), 1250);
      expect(toCents(0.29), 29);
      expect(mulDivRound(1005, 1, 10), 101); // 100.5 -> 101
      expect(mulDivRound(1004, 1, 10), 100);
      expect(formatCents(123456), r'$1,234.56');
      expect(formatCents(0), r'$0.00');
      expect(formatCents(-500), r'-$5.00');
    });
  });

  group('priceOrder', () {
    test('subtotal, per-ticket + percentage fees, tax on net + fees', () {
      final q = priceOrder([ga, vip]);
      expect(q.subtotalCents, 27300);
      // 3 paid tickets x 150 + 3% of 27300 (819) = 1269
      expect(q.feesCents, 1269);
      // 8.875% of (27300 + 1269 = 28569) = 2535.49 -> 2535
      expect(q.taxCents, 2535);
      expect(q.totalCents, 27300 + 1269 + 2535);
      expect(q.ticketCount, 3);
      expect(q.discountCents, 0);
    });

    test('zero-quantity lines are dropped; empty order is free', () {
      final q = priceOrder([
        const PriceLine(
          tierId: 'x',
          tierName: 'X',
          unitCents: 900,
          quantity: 0,
        ),
      ]);
      expect(q.lines, isEmpty);
      expect(q.totalCents, 0);
      expect(q.isFree, isTrue);
    });

    test('free RSVP tickets carry no fees or tax', () {
      final q = priceOrder([
        const PriceLine(
          tierId: 'rsvp',
          tierName: 'RSVP',
          unitCents: 0,
          quantity: 2,
        ),
      ]);
      expect(q.feesCents, 0);
      expect(q.taxCents, 0);
      expect(q.totalCents, 0);
    });

    test('percent promo discounts every tier', () {
      final p = findPromo('eventra10')!;
      final q = priceOrder([ga, vip], promo: p);
      expect(q.discountCents, 2730);
      const net = 27300 - 2730;
      expect(q.feesCents, 450 + mulDivRound(net, 300, 10000));
      expect(
        q.totalCents,
        net + q.feesCents + mulDivRound(net + q.feesCents, 8875, 100000),
      );
      expect(q.promo, p);
    });

    test('tier-restricted promo only discounts its tiers', () {
      final q = priceOrder([ga, vip], promo: findPromo('VIP20'));
      expect(q.discountCents, 2860); // 20% of 14300
    });

    test('fixed promo never exceeds the eligible amount', () {
      final small = priceOrder([
        const PriceLine(
          tierId: 'ga',
          tierName: 'GA',
          unitCents: 300,
          quantity: 1,
        ),
      ], promo: findPromo('WELCOME5'));
      expect(small.discountCents, 300);
      expect(small.feesCents, 0);
      expect(small.totalCents, 0);
      final normal = priceOrder([ga], promo: findPromo('WELCOME5'));
      expect(normal.discountCents, 500);
    });

    test('a promo that discounts nothing is not reported', () {
      final q = priceOrder([ga], promo: findPromo('VIP20'));
      expect(q.discountCents, 0);
      expect(q.promo, isNull);
    });
  });

  group('validatePromo', () {
    final lines = {'ga': 13000, 'vip': 14300};

    PromoError? err(
      String code, {
      Map<String, int>? l,
      int total = 0,
      int mine = 0,
      DateTime? at,
    }) => validatePromo(
      input: code,
      now: at ?? now,
      lines: l ?? lines,
      totalRedemptions: total,
      userRedemptions: mine,
    ).error;

    test('valid codes, case and whitespace insensitive', () {
      expect(err(' eventra10 '), isNull);
      expect(err('WELCOME5'), isNull);
      expect(err('vip20'), isNull);
    });

    test('empty and unknown', () {
      expect(err('  '), PromoError.empty);
      expect(err('NOPE'), PromoError.unknown);
    });

    test('date window: expired and not yet active', () {
      expect(err('SUMMER25'), PromoError.expired);
      expect(err('SUMMER25', at: DateTime(2026, 7)), isNull);
      expect(
        err('EVENTRA10', at: DateTime(2025, 12, 31)),
        PromoError.notYetActive,
      );
      expect(err('EVENTRA10', at: DateTime(2028)), PromoError.expired);
    });

    test('usage limits: global cap and per user', () {
      expect(err('FLASH50'), PromoError.exhausted);
      expect(err('WELCOME5', mine: 1), PromoError.alreadyUsed);
      expect(err('EVENTRA10', mine: 5, total: 999), isNull);
    });

    test('tier restriction and minimum spend', () {
      expect(err('VIP20', l: {'ga': 13000}), PromoError.notApplicable);
      expect(err('WELCOME5', l: {'ga': 900}), PromoError.minSubtotal);
    });
  });

  group('tier rules', () {
    TierAvailability avail(
      String id, {
      int cap = 20,
      int sold = 0,
      int held = 0,
    }) => TierAvailability(
      tier: TicketTier(id: id, name: id, price: 10, capacity: cap, sold: sold),
      capacity: cap,
      sold: sold,
      held: held,
    );

    test('availability, low stock and sold out', () {
      final a = avail('ga', cap: 30, sold: 15, held: 6);
      expect(a.available, 9);
      expect(a.lowStock, isTrue);
      expect(avail('ga', cap: 10, sold: 10).soldOut, isTrue);
      expect(avail('ga', cap: 100).lowStock, isFalse);
    });

    test('selection clamps to tier max, stock and order max of 8', () {
      expect(clampSelection(selection: {}, tier: avail('vip'), wanted: 9), 4);
      expect(
        clampSelection(selection: {}, tier: avail('ga', cap: 3), wanted: 5),
        3,
      );
      expect(
        clampSelection(
          selection: {'vip': 4, 'early': 2},
          tier: avail('ga'),
          wanted: 8,
        ),
        2,
      );
      expect(clampSelection(selection: {}, tier: avail('ga'), wanted: -1), 0);
    });
  });
}
