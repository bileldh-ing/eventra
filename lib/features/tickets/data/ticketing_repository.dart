import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:eventra/core/crypto/pbkdf2.dart';
import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/features/tickets/domain/pricing.dart';
import 'package:eventra/features/tickets/domain/promo.dart';
import 'package:eventra/features/tickets/domain/refund_policy.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/domain/tier_rules.dart';
import 'package:meta/meta.dart';

/// Everything the buyer confirmed on the checkout screen.
@immutable
class CheckoutRequest {
  const CheckoutRequest({
    required this.holdId,
    required this.userId,
    required this.event,
    required this.attendeeName,
    required this.attendeeEmail,
    required this.idempotencyKey,
    this.promoCode,
    this.method,
    this.authenticate,
  });

  final String holdId;
  final String userId;
  final Event event;
  final String attendeeName;
  final String attendeeEmail;

  /// Generated once per checkout attempt; a double tap or a retry after a
  /// lost response reuses it and gets the same order back.
  final String idempotencyKey;
  final String? promoCode;

  /// Required unless the order total is zero.
  final PaymentMethod? method;
  final AuthenticateCallback? authenticate;
}

class _Abort implements Exception {
  const _Abort(this.failure);
  final TicketingFailure failure;
}

/// Price lines for a hold, from the event's tiers.
List<PriceLine> linesFor(Event event, List<HoldLine> lines) => [
  for (final l in lines)
    for (final t in event.tiers)
      if (t.id == l.tierId)
        PriceLine(
          tierId: t.id,
          tierName: t.name,
          unitCents: toCents(t.price),
          quantity: l.quantity,
        ),
];

/// Ticketing on the local database: live stock, 10-minute holds, idempotent
/// orders, tickets and refunds. Every stock change is a single conditional
/// UPDATE inside a transaction, and the table's CHECK constraint rejects
/// anything that would oversell.
class TicketingRepository {
  TicketingRepository({
    required this.db,
    required this.gateway,
    DateTime Function()? clock,
    this.holdTtl = const Duration(minutes: 10),
    String Function(String prefix)? ids,
  }) : _clock = clock ?? DateTime.now,
       _ids = ids ?? newId;

  final AppDatabase db;
  final PaymentGateway gateway;
  final DateTime Function() _clock;
  final Duration holdTtl;
  final String Function(String prefix) _ids;

  final _inflight = <String, Future<Result<Order>>>{};

  static String newId(String prefix) =>
      '${prefix}_${base64UrlNoPad(secureRandomBytes(12))}';

  int get _nowMs => _clock().millisecondsSinceEpoch;

  // ---------------------------------------------------------------- stock

  Future<void> _ensureStock(Event e) async {
    for (final t in e.tiers) {
      await db.customInsert(
        'INSERT OR IGNORE INTO tier_stock '
        '(event_id, tier_id, capacity, sold, held) VALUES (?, ?, ?, ?, 0)',
        variables: [
          Variable.withString(e.id),
          Variable.withString(t.id),
          Variable.withInt(t.capacity),
          Variable.withInt(t.sold.clamp(0, t.capacity)),
        ],
      );
    }
  }

  /// Releases seats of holds whose 10 minutes ran out. Returns how many
  /// holds expired.
  Future<int> sweepExpired() => db.transaction(_sweep);

  Future<int> _sweep() async {
    final expired = await db
        .customSelect(
          "SELECT id FROM ticket_holds WHERE status = 'active' "
          'AND expires_at <= ?',
          variables: [Variable.withInt(_nowMs)],
        )
        .get();
    for (final row in expired) {
      await _releaseSeats(row.read<String>('id'), HoldStatus.expired);
    }
    return expired.length;
  }

  Future<void> _releaseSeats(String holdId, HoldStatus to) async {
    final hold = await db
        .customSelect(
          'SELECT event_id, status FROM ticket_holds WHERE id = ?',
          variables: [Variable.withString(holdId)],
        )
        .getSingleOrNull();
    if (hold == null || hold.read<String>('status') != 'active') return;
    final eventId = hold.read<String>('event_id');
    for (final item in await _holdItems(holdId)) {
      await db.customUpdate(
        'UPDATE tier_stock SET held = held - ? '
        'WHERE event_id = ? AND tier_id = ? AND held >= ?',
        variables: [
          Variable.withInt(item.quantity),
          Variable.withString(eventId),
          Variable.withString(item.tierId),
          Variable.withInt(item.quantity),
        ],
      );
    }
    await db.customUpdate(
      'UPDATE ticket_holds SET status = ? WHERE id = ?',
      variables: [Variable.withString(to.name), Variable.withString(holdId)],
    );
  }

  /// Live availability for each of the event's tiers (in tier order).
  Future<List<TierAvailability>> availability(Event event) async {
    await _ensureStock(event);
    await sweepExpired();
    final rows = await db
        .customSelect(
          'SELECT tier_id, capacity, sold, held FROM tier_stock '
          'WHERE event_id = ?',
          variables: [Variable.withString(event.id)],
        )
        .get();
    final byTier = {for (final r in rows) r.read<String>('tier_id'): r};
    return [
      for (final t in event.tiers)
        if (byTier[t.id] case final r?)
          TierAvailability(
            tier: t,
            capacity: r.read<int>('capacity'),
            sold: r.read<int>('sold'),
            held: r.read<int>('held'),
          ),
    ];
  }

  // ---------------------------------------------------------------- holds

  /// Reserves seats for [holdTtl]. Any earlier active hold by the same user
  /// for the same event is released first. All-or-nothing: if one tier no
  /// longer has enough seats nothing is reserved.
  Future<Result<TicketHold>> createHold({
    required String userId,
    required Event event,
    required Map<String, int> quantities,
  }) async {
    final lines = <HoldLine>[];
    var total = 0;
    for (final MapEntry(key: tierId, value: q) in quantities.entries) {
      if (q < 0) return _fail(TicketingError.invalidSelection, 'Bad quantity.');
      if (q == 0) continue;
      final tier = event.tiers.where((t) => t.id == tierId).firstOrNull;
      if (tier == null) {
        return _fail(TicketingError.invalidSelection, 'Unknown ticket type.');
      }
      if (q > perOrderMaxFor(tierId)) {
        return _fail(
          TicketingError.invalidSelection,
          'You can buy up to ${perOrderMaxFor(tierId)} ${tier.name} tickets.',
        );
      }
      total += q;
      lines.add(HoldLine(tierId: tierId, quantity: q));
    }
    if (total == 0) {
      return _fail(TicketingError.invalidSelection, 'Choose a ticket first.');
    }
    if (total > kMaxTicketsPerOrder) {
      return _fail(
        TicketingError.invalidSelection,
        'You can buy up to $kMaxTicketsPerOrder tickets per order.',
      );
    }
    await _ensureStock(event);
    final now = _clock();
    final hold = TicketHold(
      id: _ids('hold'),
      userId: userId,
      eventId: event.id,
      createdAt: now,
      expiresAt: now.add(holdTtl),
      status: HoldStatus.active,
      lines: lines,
    );
    try {
      await db.transaction(() async {
        await _sweep();
        final previous = await db
            .customSelect(
              "SELECT id FROM ticket_holds WHERE status = 'active' "
              'AND user_id = ? AND event_id = ?',
              variables: [
                Variable.withString(userId),
                Variable.withString(event.id),
              ],
            )
            .get();
        for (final p in previous) {
          await _releaseSeats(p.read<String>('id'), HoldStatus.released);
        }
        for (final l in lines) {
          final changed = await db.customUpdate(
            'UPDATE tier_stock SET held = held + ? WHERE event_id = ? '
            'AND tier_id = ? AND capacity - sold - held >= ?',
            variables: [
              Variable.withInt(l.quantity),
              Variable.withString(event.id),
              Variable.withString(l.tierId),
              Variable.withInt(l.quantity),
            ],
          );
          if (changed == 0) {
            final name = event.tiers.firstWhere((t) => t.id == l.tierId).name;
            throw _Abort(
              TicketingFailure(
                TicketingError.soldOut,
                'Not enough $name tickets left. Update your selection.',
              ),
            );
          }
        }
        await db.customInsert(
          'INSERT INTO ticket_holds '
          '(id, user_id, event_id, created_at, expires_at, status) '
          "VALUES (?, ?, ?, ?, ?, 'active')",
          variables: [
            Variable.withString(hold.id),
            Variable.withString(userId),
            Variable.withString(event.id),
            Variable.withInt(now.millisecondsSinceEpoch),
            Variable.withInt(hold.expiresAt.millisecondsSinceEpoch),
          ],
        );
        for (final l in lines) {
          await db.customInsert(
            'INSERT INTO ticket_hold_items (hold_id, tier_id, quantity) '
            'VALUES (?, ?, ?)',
            variables: [
              Variable.withString(hold.id),
              Variable.withString(l.tierId),
              Variable.withInt(l.quantity),
            ],
          );
        }
      });
    } on _Abort catch (a) {
      return Result.failure(a.failure);
    }
    return Result.success(hold);
  }

  Future<List<HoldLine>> _holdItems(String holdId) async => [
    for (final r
        in await db
            .customSelect(
              'SELECT tier_id, quantity FROM ticket_hold_items '
              'WHERE hold_id = ? ORDER BY rowid',
              variables: [Variable.withString(holdId)],
            )
            .get())
      HoldLine(
        tierId: r.read<String>('tier_id'),
        quantity: r.read<int>('quantity'),
      ),
  ];

  Future<TicketHold?> hold(String id) async {
    final r = await db
        .customSelect(
          'SELECT * FROM ticket_holds WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    if (r == null) return null;
    return TicketHold(
      id: id,
      userId: r.read<String>('user_id'),
      eventId: r.read<String>('event_id'),
      createdAt: _time(r.read<int>('created_at')),
      expiresAt: _time(r.read<int>('expires_at')),
      status: HoldStatus.values.byName(r.read<String>('status')),
      lines: await _holdItems(id),
    );
  }

  /// Gives the seats back (checkout cancelled). No-op if not active.
  Future<void> releaseHold(String id) =>
      db.transaction(() => _releaseSeats(id, HoldStatus.released));

  // ---------------------------------------------------------------- promo

  Future<int> redemptions(String code, {String? userId}) async {
    final r = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM promo_redemptions WHERE code = ?'
          '${userId == null ? '' : ' AND user_id = ?'}',
          variables: [
            Variable.withString(code.trim().toUpperCase()),
            if (userId != null) Variable.withString(userId),
          ],
        )
        .getSingle();
    return r.read<int>('n');
  }

  /// Checks [input] for this user and these lines (date, usage limits,
  /// tier restrictions, minimum spend).
  Future<PromoCheck> checkPromo({
    required String input,
    required String userId,
    required List<PriceLine> lines,
  }) async {
    final code = input.trim().toUpperCase();
    return validatePromo(
      input: input,
      now: _clock(),
      lines: {for (final l in lines) l.tierId: l.subtotalCents},
      totalRedemptions: code.isEmpty ? 0 : await redemptions(code),
      userRedemptions: code.isEmpty
          ? 0
          : await redemptions(code, userId: userId),
    );
  }

  // --------------------------------------------------------------- orders

  /// Charges and turns a hold into an order with one ticket per seat.
  /// Idempotent on [CheckoutRequest.idempotencyKey]: concurrent or repeated
  /// calls with the same key charge once and return the same order.
  Future<Result<Order>> placeOrder(CheckoutRequest r) {
    final key = r.idempotencyKey;
    final running = _inflight[key];
    if (running != null) return running;
    // The callback must not return the removed future (whenComplete would
    // wait on itself).
    final future = _placeOrder(r).whenComplete(() {
      _inflight.remove(key);
    });
    return _inflight[key] = future;
  }

  Future<Result<Order>> _placeOrder(CheckoutRequest r) async {
    final existing = await orderByKey(r.idempotencyKey);
    if (existing != null) return Result.success(existing);

    final hold = await this.hold(r.holdId);
    if (hold == null || hold.userId != r.userId) {
      return _fail(TicketingError.holdNotFound, 'Your selection was lost.');
    }
    if (!hold.isLive(_clock())) {
      await sweepExpired();
      return _fail(
        TicketingError.holdExpired,
        'Your 10-minute hold ended and the tickets were released.',
      );
    }

    final lines = linesFor(r.event, hold.lines);
    PromoCode? promo;
    final code = r.promoCode?.trim() ?? '';
    if (code.isNotEmpty) {
      final check = await checkPromo(
        input: code,
        userId: r.userId,
        lines: lines,
      );
      if (!check.ok) {
        return _fail(TicketingError.promoInvalid, check.error!.message);
      }
      promo = check.promo;
    }
    final quote = priceOrder(lines, promo: promo);

    ChargeResult? charge;
    if (quote.totalCents > 0) {
      final method = r.method;
      if (method == null) {
        return _fail(TicketingError.paymentDeclined, 'Choose how to pay.');
      }
      charge = await gateway.charge(
        idempotencyKey: r.idempotencyKey,
        amountCents: quote.totalCents,
        method: method,
        authenticate: r.authenticate ?? (_) async => true,
      );
      if (!charge.succeeded) {
        final code = switch (charge.status) {
          ChargeStatus.timeout => TicketingError.paymentTimeout,
          ChargeStatus.authenticationFailed =>
            TicketingError.authenticationFailed,
          _ => TicketingError.paymentDeclined,
        };
        return _fail(code, charge.message ?? 'The payment failed.');
      }
    }

    final order = Order(
      id: _ids('ord'),
      userId: r.userId,
      idempotencyKey: r.idempotencyKey,
      status: OrderStatus.paid,
      event: snapshotOf(r.event),
      lines: quote.lines,
      subtotalCents: quote.subtotalCents,
      discountCents: quote.discountCents,
      feesCents: quote.feesCents,
      taxCents: quote.taxCents,
      totalCents: quote.totalCents,
      refundCents: 0,
      attendeeName: r.attendeeName.trim(),
      attendeeEmail: r.attendeeEmail.trim(),
      createdAt: _clock(),
      promoCode: quote.promo?.code,
      paymentRef: charge?.reference,
      cardBrand: charge == null ? null : r.method!.brand.label,
      cardLast4: charge == null ? null : r.method!.last4,
      tickets: [
        for (final l in quote.lines)
          for (var i = 0; i < l.quantity; i++)
            Ticket(
              id: _ids('tkt'),
              orderId: '',
              userId: r.userId,
              eventId: r.event.id,
              tierId: l.tierId,
              tierName: l.tierName,
              holderName: r.attendeeName.trim(),
              status: TicketStatus.valid,
              seq: 0,
            ),
      ],
    );

    try {
      final saved = await db.transaction(() async {
        final raced = await orderByKey(r.idempotencyKey);
        if (raced != null) return raced;
        await _convertHold(hold, r.event);
        await _insertOrder(order);
        return (await orderById(order.id))!;
      });
      return Result.success(saved);
    } on _Abort catch (a) {
      // Stock vanished while paying (the hold had lapsed): give the money
      // back rather than oversell.
      if (charge?.reference case final ref?) {
        await gateway.refund(reference: ref, amountCents: quote.totalCents);
      }
      return Result.failure(a.failure);
    }
  }

  Future<void> _convertHold(TicketHold hold, Event event) async {
    final row = await db
        .customSelect(
          'SELECT status FROM ticket_holds WHERE id = ?',
          variables: [Variable.withString(hold.id)],
        )
        .getSingle();
    final stillHeld = row.read<String>('status') == 'active';
    for (final l in hold.lines) {
      final changed = stillHeld
          ? await db.customUpdate(
              'UPDATE tier_stock SET held = held - ?, sold = sold + ? '
              'WHERE event_id = ? AND tier_id = ? AND held >= ?',
              variables: [
                Variable.withInt(l.quantity),
                Variable.withInt(l.quantity),
                Variable.withString(event.id),
                Variable.withString(l.tierId),
                Variable.withInt(l.quantity),
              ],
            )
          : await db.customUpdate(
              'UPDATE tier_stock SET sold = sold + ? WHERE event_id = ? '
              'AND tier_id = ? AND capacity - sold - held >= ?',
              variables: [
                Variable.withInt(l.quantity),
                Variable.withString(event.id),
                Variable.withString(l.tierId),
                Variable.withInt(l.quantity),
              ],
            );
      if (changed == 0) {
        throw const _Abort(
          TicketingFailure(
            TicketingError.soldOut,
            'Those tickets sold out while you were paying. '
            'You have not been charged.',
          ),
        );
      }
    }
    await db.customUpdate(
      "UPDATE ticket_holds SET status = 'converted' WHERE id = ?",
      variables: [Variable.withString(hold.id)],
    );
  }

  Future<void> _insertOrder(Order o) async {
    await db.customInsert(
      'INSERT INTO orders (id, user_id, idempotency_key, status, event_id, '
      'event_json, subtotal_cents, discount_cents, fees_cents, tax_cents, '
      'total_cents, refund_cents, promo_code, payment_ref, card_brand, '
      'card_last4, attendee_name, attendee_email, created_at) '
      "VALUES (?, ?, ?, 'paid', ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?, ?)",
      variables: [
        Variable.withString(o.id),
        Variable.withString(o.userId),
        Variable.withString(o.idempotencyKey),
        Variable.withString(o.event.id),
        Variable.withString(jsonEncode(_snapshotJson(o.event))),
        Variable.withInt(o.subtotalCents),
        Variable.withInt(o.discountCents),
        Variable.withInt(o.feesCents),
        Variable.withInt(o.taxCents),
        Variable.withInt(o.totalCents),
        Variable<String>(o.promoCode),
        Variable<String>(o.paymentRef),
        Variable<String>(o.cardBrand),
        Variable<String>(o.cardLast4),
        Variable.withString(o.attendeeName),
        Variable.withString(o.attendeeEmail),
        Variable.withInt(o.createdAt.millisecondsSinceEpoch),
      ],
    );
    for (final l in o.lines) {
      await db.customInsert(
        'INSERT INTO order_items '
        '(order_id, tier_id, tier_name, quantity, unit_cents) '
        'VALUES (?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(o.id),
          Variable.withString(l.tierId),
          Variable.withString(l.tierName),
          Variable.withInt(l.quantity),
          Variable.withInt(l.unitCents),
        ],
      );
    }
    var seq = 0;
    for (final t in o.tickets) {
      await db.customInsert(
        'INSERT INTO tickets (id, order_id, user_id, event_id, tier_id, '
        'tier_name, holder_name, status, seq) '
        "VALUES (?, ?, ?, ?, ?, ?, ?, 'valid', ?)",
        variables: [
          Variable.withString(t.id),
          Variable.withString(o.id),
          Variable.withString(t.userId),
          Variable.withString(t.eventId),
          Variable.withString(t.tierId),
          Variable.withString(t.tierName),
          Variable.withString(t.holderName),
          Variable.withInt(++seq),
        ],
      );
    }
    if (o.promoCode case final code?) {
      await db.customInsert(
        'INSERT INTO promo_redemptions (order_id, code, user_id, created_at) '
        'VALUES (?, ?, ?, ?)',
        variables: [
          Variable.withString(o.id),
          Variable.withString(code),
          Variable.withString(o.userId),
          Variable.withInt(o.createdAt.millisecondsSinceEpoch),
        ],
      );
    }
  }

  // -------------------------------------------------------------- refunds

  /// Cancels an order under [RefundPolicy]: refunds the payment, marks its
  /// tickets Cancelled, restores stock and frees the promo use. Calling it
  /// again on a refunded order returns that order unchanged.
  Future<Result<Order>> refundOrder(
    String orderId, {
    required String userId,
  }) async {
    final order = await orderById(orderId);
    if (order == null || order.userId != userId) {
      return _fail(TicketingError.orderNotFound, 'Order not found.');
    }
    if (order.status == OrderStatus.refunded) return Result.success(order);
    if (order.tickets.any((t) => t.status == TicketStatus.used)) {
      return _fail(
        TicketingError.refundNotAllowed,
        'A ticket in this order was already used.',
      );
    }
    final decision = RefundPolicy.evaluate(
      eventStart: order.event.startAt,
      now: _clock(),
      paidCents: order.totalCents,
    );
    if (!decision.allowed) {
      return _fail(TicketingError.refundNotAllowed, decision.reason);
    }
    if (order.paymentRef case final ref? when decision.refundCents > 0) {
      final ok = await gateway.refund(
        reference: ref,
        amountCents: decision.refundCents,
      );
      if (!ok) {
        return _fail(
          TicketingError.refundNotAllowed,
          'The refund could not be processed. Try again.',
        );
      }
    }
    await db.transaction(() async {
      final changed = await db.customUpdate(
        "UPDATE orders SET status = 'refunded', refund_cents = ?, "
        "refunded_at = ? WHERE id = ? AND status = 'paid'",
        variables: [
          Variable.withInt(decision.refundCents),
          Variable.withInt(_nowMs),
          Variable.withString(orderId),
        ],
      );
      if (changed == 0) return;
      for (final l in order.lines) {
        await db.customUpdate(
          'UPDATE tier_stock SET sold = sold - ? '
          'WHERE event_id = ? AND tier_id = ? AND sold >= ?',
          variables: [
            Variable.withInt(l.quantity),
            Variable.withString(order.eventId),
            Variable.withString(l.tierId),
            Variable.withInt(l.quantity),
          ],
        );
      }
      await db.customUpdate(
        "UPDATE tickets SET status = 'cancelled' WHERE order_id = ?",
        variables: [Variable.withString(orderId)],
      );
      await db.customUpdate(
        'DELETE FROM promo_redemptions WHERE order_id = ?',
        variables: [Variable.withString(orderId)],
      );
    });
    return Result.success((await orderById(orderId))!);
  }

  // -------------------------------------------------------------- queries

  Future<Order?> orderByKey(String key) => _orderWhere('idempotency_key', key);

  Future<Order?> orderById(String id) => _orderWhere('id', id);

  /// Demo data: a paid order for an event that already happened, so the
  /// demo account can try reviews. Idempotent per user and event.
  Future<void> ensureDemoPastOrder({
    required String userId,
    required String attendeeName,
    required String attendeeEmail,
    required Event event,
  }) async {
    final id = 'ord_demo_${userId}_${event.id}';
    if (event.tiers.isEmpty || await orderById(id) != null) return;
    final tier = event.tiers.first;
    final unit = toCents(tier.price);
    final order = Order(
      id: id,
      userId: userId,
      idempotencyKey: 'demo:$id',
      status: OrderStatus.paid,
      event: snapshotOf(event),
      lines: [
        PriceLine(
          tierId: tier.id,
          tierName: tier.name,
          unitCents: unit,
          quantity: 1,
        ),
      ],
      subtotalCents: unit,
      discountCents: 0,
      feesCents: 0,
      taxCents: 0,
      totalCents: unit,
      refundCents: 0,
      attendeeName: attendeeName,
      attendeeEmail: attendeeEmail,
      createdAt: event.startAt.subtract(const Duration(days: 14)),
      paymentRef: 'demo',
      cardBrand: 'Visa',
      cardLast4: '4242',
      tickets: [
        Ticket(
          id: 'tkt_demo_${userId}_${event.id}',
          orderId: id,
          userId: userId,
          eventId: event.id,
          tierId: tier.id,
          tierName: tier.name,
          holderName: attendeeName,
          status: TicketStatus.valid,
          seq: 1,
        ),
      ],
    );
    await db.transaction(() => _insertOrder(order));
  }

  Future<Order?> _orderWhere(String column, String value) async {
    final r = await db
        .customSelect(
          'SELECT * FROM orders WHERE $column = ?',
          variables: [Variable.withString(value)],
        )
        .getSingleOrNull();
    return r == null ? null : _toOrder(r);
  }

  /// The user's orders, newest first, with their tickets.
  Future<List<Order>> ordersFor(String userId) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
          variables: [Variable.withString(userId)],
        )
        .get();
    return [for (final r in rows) await _toOrder(r)];
  }

  /// Every ticket the user holds, each with its order.
  Future<List<TicketEntry>> ticketsFor(String userId) async => [
    for (final o in await ordersFor(userId))
      for (final t in o.tickets) TicketEntry(t, o),
  ];

  Future<TicketEntry?> ticketEntry(String ticketId, {String? userId}) async {
    final r = await db
        .customSelect(
          'SELECT order_id, user_id FROM tickets WHERE id = ?',
          variables: [Variable.withString(ticketId)],
        )
        .getSingleOrNull();
    if (r == null) return null;
    if (userId != null && r.read<String>('user_id') != userId) return null;
    final order = await orderById(r.read<String>('order_id'));
    final ticket = order?.tickets.where((t) => t.id == ticketId).firstOrNull;
    return ticket == null ? null : TicketEntry(ticket, order!);
  }

  Future<Order> _toOrder(QueryRow r) async {
    final id = r.read<String>('id');
    final items = await db
        .customSelect(
          'SELECT * FROM order_items WHERE order_id = ? ORDER BY rowid',
          variables: [Variable.withString(id)],
        )
        .get();
    final tickets = await db
        .customSelect(
          'SELECT * FROM tickets WHERE order_id = ? ORDER BY seq',
          variables: [Variable.withString(id)],
        )
        .get();
    final refundedAt = r.read<int?>('refunded_at');
    return Order(
      id: id,
      userId: r.read<String>('user_id'),
      idempotencyKey: r.read<String>('idempotency_key'),
      status: OrderStatus.values.byName(r.read<String>('status')),
      event: _snapshotFrom(
        jsonDecode(r.read<String>('event_json')) as Map<String, dynamic>,
      ),
      lines: [
        for (final i in items)
          PriceLine(
            tierId: i.read<String>('tier_id'),
            tierName: i.read<String>('tier_name'),
            unitCents: i.read<int>('unit_cents'),
            quantity: i.read<int>('quantity'),
          ),
      ],
      subtotalCents: r.read<int>('subtotal_cents'),
      discountCents: r.read<int>('discount_cents'),
      feesCents: r.read<int>('fees_cents'),
      taxCents: r.read<int>('tax_cents'),
      totalCents: r.read<int>('total_cents'),
      refundCents: r.read<int>('refund_cents'),
      attendeeName: r.read<String>('attendee_name'),
      attendeeEmail: r.read<String>('attendee_email'),
      createdAt: _time(r.read<int>('created_at')),
      promoCode: r.read<String?>('promo_code'),
      paymentRef: r.read<String?>('payment_ref'),
      cardBrand: r.read<String?>('card_brand'),
      cardLast4: r.read<String?>('card_last4'),
      refundedAt: refundedAt == null ? null : _time(refundedAt),
      tickets: [
        for (final t in tickets)
          Ticket(
            id: t.read<String>('id'),
            orderId: id,
            userId: t.read<String>('user_id'),
            eventId: t.read<String>('event_id'),
            tierId: t.read<String>('tier_id'),
            tierName: t.read<String>('tier_name'),
            holderName: t.read<String>('holder_name'),
            status: TicketStatus.values.byName(t.read<String>('status')),
            seq: t.read<int>('seq'),
          ),
      ],
    );
  }

  // -------------------------------------------------------------- helpers

  static EventSnapshot snapshotOf(Event e) => EventSnapshot(
    id: e.id,
    title: e.title,
    startAt: e.startAt,
    endAt: e.endAt,
    venue: e.venue,
    address: e.address,
    coverImageUrl: e.coverImageUrl,
    latitude: e.latitude,
    longitude: e.longitude,
  );

  static Map<String, dynamic> _snapshotJson(EventSnapshot e) => {
    'id': e.id,
    'title': e.title,
    'startAt': e.startAt.millisecondsSinceEpoch,
    'endAt': e.endAt.millisecondsSinceEpoch,
    'venue': e.venue,
    'address': e.address,
    'cover': e.coverImageUrl,
    'lat': e.latitude,
    'lng': e.longitude,
  };

  static EventSnapshot _snapshotFrom(Map<String, dynamic> j) => EventSnapshot(
    id: j['id'] as String,
    title: j['title'] as String,
    startAt: _time(j['startAt'] as int),
    endAt: _time(j['endAt'] as int),
    venue: j['venue'] as String,
    address: j['address'] as String,
    coverImageUrl: j['cover'] as String,
    latitude: (j['lat'] as num).toDouble(),
    longitude: (j['lng'] as num).toDouble(),
  );

  static DateTime _time(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

  static Result<T> _fail<T>(TicketingError code, String message) =>
      Result.failure(TicketingFailure(code, message));
}
