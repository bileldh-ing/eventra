import 'package:meta/meta.dart';

enum PromoKind { percent, fixed }

/// A promo code. [value] is basis points for percent codes (1000 = 10%) and
/// cents for fixed codes.
@immutable
class PromoCode {
  const PromoCode({
    required this.code,
    required this.kind,
    required this.value,
    required this.validFrom,
    required this.validUntil,
    required this.label,
    this.tierIds,
    this.maxRedemptions,
    this.seededRedemptions = 0,
    this.perUserLimit,
    this.minSubtotalCents = 0,
  });

  final String code;
  final PromoKind kind;
  final int value;
  final DateTime validFrom;

  /// Exclusive end.
  final DateTime validUntil;
  final String label;

  /// Only these tiers are discounted (null = every tier).
  final Set<String>? tierIds;

  /// Global redemption cap across all users.
  final int? maxRedemptions;

  /// Redemptions that happened before this device (demo data).
  final int seededRedemptions;
  final int? perUserLimit;
  final int minSubtotalCents;

  bool appliesTo(String tierId) => tierIds == null || tierIds!.contains(tierId);
}

/// Demo codes. Real codes would come from the backend.
final kPromoCodes = <PromoCode>[
  PromoCode(
    code: 'EVENTRA10',
    kind: PromoKind.percent,
    value: 1000,
    validFrom: DateTime(2026),
    validUntil: DateTime(2028),
    label: '10% off',
  ),
  PromoCode(
    code: 'WELCOME5',
    kind: PromoKind.fixed,
    value: 500,
    validFrom: DateTime(2026),
    validUntil: DateTime(2028),
    label: r'$5 off your first order',
    perUserLimit: 1,
    minSubtotalCents: 1000,
  ),
  PromoCode(
    code: 'VIP20',
    kind: PromoKind.percent,
    value: 2000,
    validFrom: DateTime(2026),
    validUntil: DateTime(2028),
    label: '20% off VIP tickets',
    tierIds: const {'vip'},
  ),
  PromoCode(
    code: 'SUMMER25',
    kind: PromoKind.percent,
    value: 2500,
    validFrom: DateTime(2026, 6),
    validUntil: DateTime(2026, 9),
    label: '25% off summer events',
  ),
  PromoCode(
    code: 'FLASH50',
    kind: PromoKind.percent,
    value: 5000,
    validFrom: DateTime(2026),
    validUntil: DateTime(2028),
    label: '50% flash sale',
    maxRedemptions: 100,
    seededRedemptions: 100,
  ),
];

PromoCode? findPromo(String raw, [List<PromoCode>? codes]) {
  final code = raw.trim().toUpperCase();
  for (final p in codes ?? kPromoCodes) {
    if (p.code == code) return p;
  }
  return null;
}

enum PromoError {
  empty('Enter a promo code.'),
  unknown('That code does not exist.'),
  notYetActive('This code is not active yet.'),
  expired('This code has expired.'),
  exhausted('This code has been fully redeemed.'),
  alreadyUsed('You have already used this code.'),
  notApplicable('This code does not apply to the selected tickets.'),
  minSubtotal('Add more tickets to use this code.');

  const PromoError(this.message);
  final String message;
}

/// Outcome of checking a code against the current order.
@immutable
class PromoCheck {
  const PromoCheck.ok(PromoCode this.promo) : error = null;
  const PromoCheck.fail(PromoError this.error) : promo = null;
  final PromoCode? promo;
  final PromoError? error;
  bool get ok => promo != null;
}

/// Validates date window, global and per-user usage limits, tier
/// restrictions and minimum spend. [lines] maps tier id to its line
/// subtotal in cents.
PromoCheck validatePromo({
  required String input,
  required DateTime now,
  required Map<String, int> lines,
  int totalRedemptions = 0,
  int userRedemptions = 0,
  List<PromoCode>? codes,
}) {
  if (input.trim().isEmpty) return const PromoCheck.fail(PromoError.empty);
  final p = findPromo(input, codes);
  if (p == null) return const PromoCheck.fail(PromoError.unknown);
  if (now.isBefore(p.validFrom)) {
    return const PromoCheck.fail(PromoError.notYetActive);
  }
  if (!now.isBefore(p.validUntil)) {
    return const PromoCheck.fail(PromoError.expired);
  }
  if (p.maxRedemptions != null &&
      p.seededRedemptions + totalRedemptions >= p.maxRedemptions!) {
    return const PromoCheck.fail(PromoError.exhausted);
  }
  if (p.perUserLimit != null && userRedemptions >= p.perUserLimit!) {
    return const PromoCheck.fail(PromoError.alreadyUsed);
  }
  final eligible = lines.entries
      .where((e) => p.appliesTo(e.key))
      .fold<int>(0, (s, e) => s + e.value);
  if (eligible == 0) return const PromoCheck.fail(PromoError.notApplicable);
  final subtotal = lines.values.fold<int>(0, (s, v) => s + v);
  if (subtotal < p.minSubtotalCents) {
    return const PromoCheck.fail(PromoError.minSubtotal);
  }
  return PromoCheck.ok(p);
}
