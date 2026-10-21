import 'package:intl/intl.dart';

/// 'Jun 20 - 11:00 PM' (home carousel card).
String formatCardDate(DateTime d) =>
    '${DateFormat('MMM d').format(d)} - ${DateFormat('h:mm a').format(d)}';

/// 'Feb 11- 10:20 PM' (details meta row, as in the reference).
String formatDetailsDate(DateTime d) =>
    '${DateFormat('MMM d').format(d)}- ${DateFormat('h:mm a').format(d)}';

/// 'Sat,Dec 24-11:00pm-01:00am' (map preview card).
String formatPreviewRange(DateTime start, DateTime end) {
  String t(DateTime x) => DateFormat('hh:mma').format(x).toLowerCase();
  return '${DateFormat('EEE,MMM d').format(start)}-${t(start)}-${t(end)}';
}

/// '$50' / '$12.50' / 'Free'.
String formatPrice(double price) {
  if (price == 0) return 'Free';
  final whole = price == price.roundToDouble();
  return '\$${whole ? price.toStringAsFixed(0) : price.toStringAsFixed(2)}';
}

/// '18.4k' style compact counts.
String formatCompact(int n) => NumberFormat.compact().format(n);
