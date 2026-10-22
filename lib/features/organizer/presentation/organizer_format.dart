import 'package:eventra/l10n/l10n.dart';
import 'package:intl/intl.dart';

final _dollars = <String, NumberFormat>{};
final _counts = <String, NumberFormat>{};
final _percents = <String, NumberFormat>{};

/// '$312,402' (dashboard figures drop the cents).
String formatWholeDollars(int cents) => _dollars
    .putIfAbsent(
      AppLocale.tag,
      () => AppLocale.isEnglish
          ? NumberFormat.currency(
              locale: 'en_US',
              symbol: r'$',
              decimalDigits: 0,
            )
          : NumberFormat.simpleCurrency(
              locale: AppLocale.tag,
              name: 'USD',
              decimalDigits: 0,
            ),
    )
    .format(cents ~/ 100);

/// '3,712' / '3 712'.
String formatCount(int n) => _counts
    .putIfAbsent(
      AppLocale.tag,
      () => NumberFormat.decimalPattern(AppLocale.tag),
    )
    .format(n);

/// '68%' / '68 %'.
String formatPercent(double v) => _percents
    .putIfAbsent(
      AppLocale.tag,
      () => NumberFormat.percentPattern(AppLocale.tag),
    )
    .format(v);
