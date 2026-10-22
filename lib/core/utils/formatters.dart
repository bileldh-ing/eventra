import 'package:eventra/l10n/l10n.dart';
import 'package:intl/intl.dart';

// Every formatter follows the active app locale ([AppLocale]). English keeps
// the exact patterns from the design reference; French and Arabic use the
// CLDR skeletons for their locale (24-hour clock in French, Arabic month
// names and AM/PM markers in Arabic).

String get _tag => AppLocale.tag;

/// 'Jun 20' / '20 juin' / '20 يونيو'.
String formatMonthDay(DateTime d) => DateFormat.MMMd(_tag).format(d);

/// '11:00 PM' / '23:00' / '11:00 م'.
String formatTime(DateTime d) => AppLocale.isEnglish
    ? DateFormat('h:mm a', 'en').format(d)
    : DateFormat.jm(_tag).format(d);

/// 'Sat, Dec 24' / 'sam. 24 déc.' / 'السبت، 24 ديسمبر'.
String formatWeekdayMonthDay(DateTime d) => AppLocale.isEnglish
    ? DateFormat('EEE, MMM d', 'en').format(d)
    : DateFormat.MMMEd(_tag).format(d);

/// 'Oct 21, 2026' / '21 oct. 2026' / '21 أكتوبر 2026'.
String formatFullDate(DateTime d) => DateFormat.yMMMd(_tag).format(d);

/// 'Oct 21, 2026 · 10:00 AM'.
String formatDateTime(DateTime d) => '${formatFullDate(d)} · ${formatTime(d)}';

/// 'Oct 21, 10:00 AM' (refund deadlines).
String formatMonthDayTime(DateTime d) =>
    '${formatMonthDay(d)}, ${formatTime(d)}';

/// 'Jun 20 - 11:00 PM' (home carousel card).
String formatCardDate(DateTime d) => '${formatMonthDay(d)} - ${formatTime(d)}';

/// 'Feb 11- 10:20 PM' (details meta row, as in the reference).
String formatDetailsDate(DateTime d) => AppLocale.isEnglish
    ? '${formatMonthDay(d)}- ${formatTime(d)}'
    : formatCardDate(d);

/// 'Sat,Dec 24-11:00pm-01:00am' (map preview card).
String formatPreviewRange(DateTime start, DateTime end) {
  if (!AppLocale.isEnglish) {
    return '${formatWeekdayMonthDay(start)} · '
        '${formatTime(start)} – ${formatTime(end)}';
  }
  String t(DateTime x) => DateFormat('hh:mma', 'en').format(x).toLowerCase();
  return '${DateFormat('EEE,MMM d', 'en').format(start)}-${t(start)}-${t(end)}';
}

/// '$50' / '$12.50' / 'Free' in the active language.
String formatPrice(double price) {
  if (price == 0) return AppLocale.l10n.priceFree;
  return formatUsd(price);
}

/// '$50', '$12.50' ('50 $US' in French, 'US$ 50' in Arabic).
String formatUsd(double amount) {
  final whole = amount == amount.roundToDouble();
  if (AppLocale.isEnglish) {
    return '\$${whole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2)}';
  }
  return NumberFormat.simpleCurrency(
    locale: _tag,
    name: 'USD',
    decimalDigits: whole ? 0 : 2,
  ).format(amount);
}

/// '18.4k' style compact counts.
String formatCompact(int n) => NumberFormat.compact(locale: _tag).format(n);

/// A plain number with [digits] decimals in the active locale ('2.5', '2,5').
String formatDecimal(num value, [int digits = 1]) =>
    NumberFormat.decimalPatternDigits(
      locale: _tag,
      decimalDigits: digits,
    ).format(value);

/// '2.5 km' in the active locale.
String formatKmShort(double km) => AppLocale.l10n.distanceKm(formatDecimal(km));

/// 'Oct 24 - Oct 30' (inclusive day range; [endExclusive] is the day after).
String formatDayRange(DateTime start, DateTime endExclusive) {
  final last = DateTime(
    endExclusive.year,
    endExclusive.month,
    endExclusive.day - 1,
  );
  return last.isAfter(start)
      ? '${formatMonthDay(start)} - ${formatMonthDay(last)}'
      : formatMonthDay(start);
}
