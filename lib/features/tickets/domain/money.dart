import 'package:eventra/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// All money in the ticketing flow is integer cents (USD). Doubles appear
/// only at the edge where the seed's tier prices are read.
int toCents(double dollars) => (dollars * 100).round();

/// Rounds `value * numerator / denominator` half up, in integers only.
int mulDivRound(int value, int numerator, int denominator) {
  assert(value >= 0 && numerator >= 0 && denominator > 0, 'non-negative');
  return (value * numerator * 2 + denominator) ~/ (denominator * 2);
}

final _usd = NumberFormat.currency(locale: 'en_US', symbol: r'$');
final _usdByLocale = <String, NumberFormat>{};

/// '$12.50', '$0.00'; negative amounts as '-$5.00'. French and Arabic use
/// their own grouping, decimal mark and symbol placement ('12,50 $US').
String formatCents(int cents) {
  final sign = cents < 0 ? '-' : '';
  final tag = AppLocale.tag;
  final f = tag == 'en'
      ? _usd
      : _usdByLocale.putIfAbsent(
          tag,
          () => NumberFormat.simpleCurrency(locale: tag, name: 'USD'),
        );
  return '$sign${f.format(cents.abs() / 100)}';
}
