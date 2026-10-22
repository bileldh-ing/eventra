import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:meta/meta.dart';

/// Most tickets one order may hold, across all tiers.
const kMaxTicketsPerOrder = 8;

/// Tiers show "Only N left" at or below this many.
const kLowStockThreshold = 10;

/// Per-order maximum for a tier. Scarce tiers (Early Bird, VIP) are capped
/// lower so one buyer cannot take them all; free RSVPs allow a plus-one.
int perOrderMaxFor(String tierId) => switch (tierId) {
  'early' => 4,
  'vip' => 4,
  'rsvp' => 2,
  'ga' => kMaxTicketsPerOrder,
  _ => 6,
};

/// Live availability of one tier, read from the stock table.
@immutable
class TierAvailability {
  const TierAvailability({
    required this.tier,
    required this.capacity,
    required this.sold,
    required this.held,
  });

  final TicketTier tier;
  final int capacity;
  final int sold;

  /// Seats reserved by active (unexpired) holds, including the user's own.
  final int held;

  String get tierId => tier.id;
  int get unitCents => toCents(tier.price);
  int get available => (capacity - sold - held).clamp(0, capacity);
  bool get soldOut => available == 0;
  bool get lowStock => !soldOut && available <= kLowStockThreshold;
  double get soldFraction =>
      capacity == 0 ? 1 : ((sold + held) / capacity).clamp(0, 1).toDouble();

  /// What the stepper allows for this tier on its own.
  int get maxSelectable {
    final cap = perOrderMaxFor(tier.id);
    return available < cap ? available : cap;
  }
}

/// Clamps a selection change so no tier exceeds its own limit and the order
/// never exceeds [kMaxTicketsPerOrder]. Returns the allowed new quantity.
int clampSelection({
  required Map<String, int> selection,
  required TierAvailability tier,
  required int wanted,
}) {
  final others = selection.entries
      .where((e) => e.key != tier.tierId)
      .fold<int>(0, (sum, e) => sum + e.value);
  final roomInOrder = kMaxTicketsPerOrder - others;
  var q = wanted;
  if (q > tier.maxSelectable) q = tier.maxSelectable;
  if (q > roomInOrder) q = roomInOrder;
  return q < 0 ? 0 : q;
}
