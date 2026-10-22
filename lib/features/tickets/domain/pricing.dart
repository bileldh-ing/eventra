import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/promo.dart';
import 'package:meta/meta.dart';

/// One tier in an order.
@immutable
class PriceLine {
  const PriceLine({
    required this.tierId,
    required this.tierName,
    required this.unitCents,
    required this.quantity,
  });

  final String tierId;
  final String tierName;
  final int unitCents;
  final int quantity;

  int get subtotalCents => unitCents * quantity;
}

/// Fee and tax schedule. Integer basis points / per-ticket cents.
@immutable
class FeeSchedule {
  const FeeSchedule({
    this.perTicketCents = 150,
    this.serviceBps = 300,
    this.taxPer100k = 8875,
  });

  /// Flat service fee per paid ticket.
  final int perTicketCents;

  /// Percentage service fee on the discounted subtotal (300 = 3%).
  final int serviceBps;

  /// Sales tax on the discounted subtotal plus fees, in 1/1000 of a percent
  /// (8875 = 8.875%, New York City).
  final int taxPer100k;
}

const kFees = FeeSchedule();

/// Full price breakdown, every amount in cents.
@immutable
class PriceQuote {
  const PriceQuote({
    required this.lines,
    required this.subtotalCents,
    required this.discountCents,
    required this.feesCents,
    required this.taxCents,
    required this.totalCents,
    this.promo,
  });

  final List<PriceLine> lines;
  final int subtotalCents;
  final int discountCents;
  final int feesCents;
  final int taxCents;
  final int totalCents;
  final PromoCode? promo;

  int get ticketCount => lines.fold(0, (s, l) => s + l.quantity);
  bool get isFree => totalCents == 0;
}

/// Prices an order. Discounts apply only to the tiers the promo covers and
/// never exceed them; fees are charged on paid tickets only and tax applies
/// to the discounted subtotal plus fees. Pure and deterministic.
PriceQuote priceOrder(
  List<PriceLine> lines, {
  PromoCode? promo,
  FeeSchedule fees = kFees,
}) {
  final active = [
    for (final l in lines)
      if (l.quantity > 0) l,
  ];
  final subtotal = active.fold<int>(0, (s, l) => s + l.subtotalCents);
  var discount = 0;
  if (promo != null) {
    final eligible = active
        .where((l) => promo.appliesTo(l.tierId))
        .fold<int>(0, (s, l) => s + l.subtotalCents);
    discount = switch (promo.kind) {
      PromoKind.percent => mulDivRound(eligible, promo.value, 10000),
      PromoKind.fixed => promo.value < eligible ? promo.value : eligible,
    };
  }
  final net = subtotal - discount;
  final paidTickets = active
      .where((l) => l.unitCents > 0)
      .fold<int>(0, (s, l) => s + l.quantity);
  final fee = net == 0
      ? 0
      : paidTickets * fees.perTicketCents +
            mulDivRound(net, fees.serviceBps, 10000);
  final tax = mulDivRound(net + fee, fees.taxPer100k, 100000);
  return PriceQuote(
    lines: active,
    subtotalCents: subtotal,
    discountCents: discount,
    feesCents: fee,
    taxCents: tax,
    totalCents: net + fee + tax,
    promo: discount > 0 ? promo : null,
  );
}
