import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

class FakeClock {
  FakeClock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

final visa = SavedCardMethod(kDemoCards.first);

Event smallEvent({int capacity = 5, int sold = 0}) {
  final base = loadSeed().events.firstWhere((e) => e.tiers.length == 3);
  return base.copyWith(
    id: 'evt-test',
    startAt: DateTime(2026, 12, 1, 20),
    endAt: DateTime(2026, 12, 1, 23),
    tiers: [
      TicketTier(
        id: 'ga',
        name: 'General Admission',
        price: 65,
        capacity: capacity,
        sold: sold,
      ),
      const TicketTier(
        id: 'vip',
        name: 'VIP',
        price: 143,
        capacity: 4,
        sold: 0,
      ),
    ],
  );
}

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late MockPaymentGateway gateway;
  late TicketingRepository repo;
  final event = smallEvent();

  setUp(() {
    db = memoryDb();
    clock = FakeClock(DateTime(2026, 10, 21, 10));
    gateway = MockPaymentGateway(latency: Duration.zero);
    repo = TicketingRepository(db: db, gateway: gateway, clock: clock.call);
  });
  tearDown(() => db.close());

  Future<int> available(String tier) async => (await repo.availability(
    event,
  )).firstWhere((a) => a.tierId == tier).available;

  Future<TicketHold> holdOf(Map<String, int> q, {String user = 'u1'}) async =>
      (await repo.createHold(
        userId: user,
        event: event,
        quantities: q,
      )).valueOrNull!;

  CheckoutRequest req(
    TicketHold h, {
    String key = 'key-1',
    PaymentMethod? method,
    String? promo,
    String user = 'u1',
    AuthenticateCallback? auth,
  }) => CheckoutRequest(
    holdId: h.id,
    userId: user,
    event: event,
    attendeeName: 'Daniel Brooks',
    attendeeEmail: 'demo@eventra.app',
    idempotencyKey: key,
    method: method ?? visa,
    promoCode: promo,
    authenticate: auth,
  );

  group('holds', () {
    test('reserve decrements availability and releases on cancel', () async {
      expect(await available('ga'), 5);
      final h = await holdOf({'ga': 3});
      expect(h.quantity, 3);
      expect(h.expiresAt, clock.now.add(const Duration(minutes: 10)));
      expect(await available('ga'), 2);
      await repo.releaseHold(h.id);
      expect(await available('ga'), 5);
      expect((await repo.hold(h.id))!.status, HoldStatus.released);
      await repo.releaseHold(h.id); // idempotent
      expect(await available('ga'), 5);
    });

    test('expiry with a fake clock frees the seats', () async {
      final h = await holdOf({'ga': 4});
      clock.advance(const Duration(minutes: 9, seconds: 59));
      expect(await available('ga'), 1);
      expect((await repo.hold(h.id))!.isLive(clock.now), isTrue);
      clock.advance(const Duration(seconds: 1));
      expect(await available('ga'), 5);
      expect((await repo.hold(h.id))!.status, HoldStatus.expired);
      final r = await repo.placeOrder(req(h));
      expect(
        ((r as Failure).failure as TicketingFailure).code,
        TicketingError.holdExpired,
      );
      expect(gateway.capturedCount, 0);
    });

    test("a new hold replaces the same user's earlier one", () async {
      await holdOf({'ga': 3});
      await holdOf({'ga': 2});
      expect(await available('ga'), 3);
    });

    test('validates selection limits', () async {
      Future<TicketingError?> code(Map<String, int> q) async {
        final r = await repo.createHold(
          userId: 'u1',
          event: event,
          quantities: q,
        );
        return r is Failure<TicketHold>
            ? (r.failure as TicketingFailure).code
            : null;
      }

      expect(await code({}), TicketingError.invalidSelection);
      expect(await code({'ga': 0}), TicketingError.invalidSelection);
      expect(await code({'nope': 1}), TicketingError.invalidSelection);
      expect(await code({'vip': 5}), TicketingError.invalidSelection);
      expect(await code({'ga': -1}), TicketingError.invalidSelection);
      expect(await code({'ga': 6}), TicketingError.soldOut);
      expect(await available('ga'), 5);
    });

    test('all-or-nothing when one tier lacks seats', () async {
      await holdOf({'vip': 4}, user: 'other');
      final r = await repo.createHold(
        userId: 'u1',
        event: event,
        quantities: {'ga': 2, 'vip': 1},
      );
      expect(r.isSuccess, isFalse);
      expect(await available('ga'), 5);
      expect(await available('vip'), 0);
    });

    test('no oversell under 20 concurrent buyers for 5 seats', () async {
      final results = await Future.wait([
        for (var i = 0; i < 20; i++)
          repo.createHold(
            userId: 'user$i',
            event: event,
            quantities: {'ga': 1},
          ),
      ]);
      expect(results.where((r) => r.isSuccess), hasLength(5));
      expect(await available('ga'), 0);
      final stock = await db
          .customSelect(
            "SELECT sold, held FROM tier_stock WHERE tier_id = 'ga'",
          )
          .getSingle();
      expect(stock.read<int>('held'), 5);
      expect(stock.read<int>('sold'), 0);
    });

    test('database CHECK rejects an oversell even from raw SQL', () async {
      await repo.availability(event);
      expect(
        () => db.customStatement(
          "UPDATE tier_stock SET sold = capacity + 1 WHERE tier_id = 'ga'",
        ),
        throwsA(anything),
      );
    });
  });

  group('orders', () {
    test(
      'converts the hold, issues one ticket per seat, totals in cents',
      () async {
        final h = await holdOf({'ga': 2, 'vip': 1});
        final r = await repo.placeOrder(req(h));
        final order = r.valueOrNull!;
        expect(order.subtotalCents, 27300);
        expect(order.totalCents, 27300 + 1269 + 2535);
        expect(order.tickets, hasLength(3));
        expect(order.tickets.map((t) => t.seq), [1, 2, 3]);
        expect(order.cardLast4, '4242');
        expect(order.paymentRef, startsWith('ch_'));
        expect(gateway.capturedCount, 1);
        final a = await repo.availability(event);
        expect(a.firstWhere((x) => x.tierId == 'ga').sold, 2);
        expect(a.firstWhere((x) => x.tierId == 'ga').held, 0);
        expect((await repo.hold(h.id))!.status, HoldStatus.converted);
        final mine = await repo.ticketsFor('u1');
        expect(mine, hasLength(3));
        expect(await repo.ticketsFor('u2'), isEmpty);
        expect(
          await repo.ticketEntry(mine.first.ticket.id, userId: 'u2'),
          isNull,
        );
      },
    );

    test('idempotency: double tap and retries charge once', () async {
      final h = await holdOf({'ga': 1});
      final results = await Future.wait([
        repo.placeOrder(req(h)),
        repo.placeOrder(req(h)),
        repo.placeOrder(req(h)),
      ]);
      final ids = results.map((r) => r.valueOrNull!.id).toSet();
      expect(ids, hasLength(1));
      final again = await repo.placeOrder(req(h));
      expect(again.valueOrNull!.id, ids.single);
      expect(gateway.capturedCount, 1);
      expect(await repo.ordersFor('u1'), hasLength(1));
    });

    test(
      'declined card keeps the hold; a new key with a good card works',
      () async {
        final h = await holdOf({'ga': 2});
        final declined = await repo.placeOrder(
          req(
            h,
            method: NewCardMethod(
              number: '4000 0000 0000 0002',
              expiry: '12/29',
            ),
          ),
        );
        expect(
          ((declined as Failure).failure as TicketingFailure).code,
          TicketingError.paymentDeclined,
        );
        expect(await available('ga'), 3);
        final ok = await repo.placeOrder(req(h, key: 'key-2'));
        expect(ok.isSuccess, isTrue);
        expect(gateway.capturedCount, 1);
      },
    );

    test('timeout and cancelled 3-D Secure are not charged', () async {
      final h = await holdOf({'ga': 1});
      final timeout = await repo.placeOrder(
        req(
          h,
          method: NewCardMethod(number: '4000000000000119', expiry: '12/29'),
        ),
      );
      expect(
        ((timeout as Failure).failure as TicketingFailure).code,
        TicketingError.paymentTimeout,
      );
      var asked = 0;
      final cancelled = await repo.placeOrder(
        req(
          h,
          key: 'k3',
          method: SavedCardMethod(kDemoCards[1]),
          auth: (_) async {
            asked++;
            return false;
          },
        ),
      );
      expect(asked, 1);
      expect(
        ((cancelled as Failure).failure as TicketingFailure).code,
        TicketingError.authenticationFailed,
      );
      final approved = await repo.placeOrder(
        req(
          h,
          key: 'k4',
          method: SavedCardMethod(kDemoCards[1]),
          auth: (_) async => true,
        ),
      );
      expect(approved.valueOrNull!.cardLast4, '4444');
      expect(gateway.capturedCount, 1);
    });

    test('promo is applied, recorded and limited per user', () async {
      final h = await holdOf({'ga': 2});
      final o = (await repo.placeOrder(req(h, promo: 'welcome5'))).valueOrNull!;
      expect(o.discountCents, 500);
      expect(o.promoCode, 'WELCOME5');
      expect(await repo.redemptions('WELCOME5', userId: 'u1'), 1);
      final h2 = await holdOf({'ga': 1});
      final again = await repo.placeOrder(
        req(h2, key: 'k2', promo: 'WELCOME5'),
      );
      expect(
        ((again as Failure).failure as TicketingFailure).code,
        TicketingError.promoInvalid,
      );
    });

    test('lapsed hold still converts if seats remain, else refunds', () async {
      final ev = event;
      final h = await holdOf({'ga': 5});
      // Pay with a 3-D Secure card whose approval takes 11 minutes.
      final slow = repo.placeOrder(
        req(
          h,
          method: SavedCardMethod(kDemoCards[1]),
          auth: (_) async {
            clock.advance(const Duration(minutes: 11));
            // Meanwhile someone else grabs a seat.
            await repo.createHold(
              userId: 'rival',
              event: ev,
              quantities: {'ga': 1},
            );
            return true;
          },
        ),
      );
      final r = await slow;
      expect(
        ((r as Failure).failure as TicketingFailure).code,
        TicketingError.soldOut,
      );
      expect(gateway.refunds, hasLength(1));
      expect(await repo.ordersFor('u1'), isEmpty);
    });

    test('free orders need no payment', () async {
      final free = event.copyWith(
        id: 'evt-free',
        tiers: const [
          TicketTier(
            id: 'rsvp',
            name: 'Free RSVP',
            price: 0,
            capacity: 50,
            sold: 0,
          ),
        ],
      );
      final h = (await repo.createHold(
        userId: 'u1',
        event: free,
        quantities: {'rsvp': 2},
      )).valueOrNull!;
      final o = (await repo.placeOrder(
        CheckoutRequest(
          holdId: h.id,
          userId: 'u1',
          event: free,
          attendeeName: 'A',
          attendeeEmail: 'a@b.co',
          idempotencyKey: 'free-1',
        ),
      )).valueOrNull!;
      expect(o.totalCents, 0);
      expect(o.paymentRef, isNull);
      expect(gateway.capturedCount, 0);
    });
  });

  group('refunds', () {
    test(
      'full refund > 48 h: cancels tickets, restores stock and promo',
      () async {
        final h = await holdOf({'ga': 2});
        final o = (await repo.placeOrder(
          req(h, promo: 'WELCOME5'),
        )).valueOrNull!;
        expect(await available('ga'), 3);
        final r = await repo.refundOrder(o.id, userId: 'u1');
        final refunded = r.valueOrNull!;
        expect(refunded.status, OrderStatus.refunded);
        expect(refunded.refundCents, o.totalCents);
        expect(
          refunded.tickets.every((t) => t.status == TicketStatus.cancelled),
          isTrue,
        );
        expect(await available('ga'), 5);
        expect(gateway.refunds[o.paymentRef], o.totalCents);
        expect(await repo.redemptions('WELCOME5', userId: 'u1'), 0);
        // Idempotent: a second request changes nothing.
        final again = await repo.refundOrder(o.id, userId: 'u1');
        expect(again.valueOrNull!.status, OrderStatus.refunded);
        expect(await available('ga'), 5);
      },
    );

    test('no refund within 48 h; other users cannot refund', () async {
      final h = await holdOf({'ga': 1});
      final o = (await repo.placeOrder(req(h))).valueOrNull!;
      final other = await repo.refundOrder(o.id, userId: 'u2');
      expect(
        ((other as Failure).failure as TicketingFailure).code,
        TicketingError.orderNotFound,
      );
      clock.now = event.startAt.subtract(const Duration(hours: 47));
      final late = await repo.refundOrder(o.id, userId: 'u1');
      expect(
        ((late as Failure).failure as TicketingFailure).code,
        TicketingError.refundNotAllowed,
      );
      expect((await repo.orderById(o.id))!.status, OrderStatus.paid);
    });
  });
}
