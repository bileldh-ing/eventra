import 'package:eventra/l10n/l10n.dart';
import 'package:meta/meta.dart';

/// Luhn (mod 10) checksum over the digits of [input]; spaces and dashes are
/// ignored. False for anything else or fewer than 12 digits.
bool luhnValid(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  if (digits.length < 12 || digits.length > 19) return false;
  if (!RegExp(r'^\d+$').hasMatch(digits)) return false;
  var sum = 0;
  var doubleIt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var d = digits.codeUnitAt(i) - 48;
    if (doubleIt) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    doubleIt = !doubleIt;
  }
  return sum % 10 == 0;
}

enum CardBrand {
  visa('Visa', [16, 13, 19], 3),
  mastercard('Mastercard', [16], 3),
  amex('American Express', [15], 4),
  discover('Discover', [16, 19], 3),
  unknown('Card', [16], 3);

  const CardBrand(this._name, this.lengths, this.cvcLength);
  final String _name;

  /// Brand names are not translated; the generic fallback is.
  String get label => this == unknown ? AppLocale.l10n.cardGeneric : _name;
  final List<int> lengths;
  final int cvcLength;

  static CardBrand detect(String number) {
    final n = digitsOnly(number);
    if (n.startsWith('4')) return visa;
    if (RegExp(r'^(5[1-5]|2(2[2-9]|[3-6]\d|7[01]|720))').hasMatch(n)) {
      return mastercard;
    }
    if (RegExp('^3[47]').hasMatch(n)) return amex;
    if (RegExp('^(6011|65|64[4-9])').hasMatch(n)) return discover;
    return unknown;
  }
}

String digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

/// '4242 4242 4242 4242' (Amex: '3782 822463 10005').
String formatCardNumber(String raw) {
  final d = digitsOnly(raw);
  final groups = CardBrand.detect(d) == CardBrand.amex
      ? const [4, 6, 5]
      : const [4, 4, 4, 4, 3];
  final out = StringBuffer();
  var i = 0;
  for (final g in groups) {
    if (i >= d.length) break;
    if (out.isNotEmpty) out.write(' ');
    final end = i + g > d.length ? d.length : i + g;
    out.write(d.substring(i, end));
    i = end;
  }
  return out.toString();
}

String? validateCardNumber(String raw) {
  final d = digitsOnly(raw);
  if (d.isEmpty) return AppLocale.l10n.cardEnterNumber;
  final brand = CardBrand.detect(d);
  if (!brand.lengths.contains(d.length) && brand != CardBrand.unknown) {
    return AppLocale.l10n.cardIncomplete(brand.label);
  }
  if (!luhnValid(d)) return AppLocale.l10n.cardInvalid;
  return null;
}

/// [raw] as 'MM/YY'. Cards are valid through the end of their month.
String? validateExpiry(String raw, DateTime now) {
  final m = RegExp(r'^(\d{2})\s*/\s*(\d{2})$').firstMatch(raw.trim());
  if (m == null) return AppLocale.l10n.cardUseMmYy;
  final month = int.parse(m.group(1)!);
  final year = 2000 + int.parse(m.group(2)!);
  if (month < 1 || month > 12) return AppLocale.l10n.cardUseMmYy;
  if (!now.isBefore(DateTime(year, month + 1))) {
    return AppLocale.l10n.cardExpired;
  }
  if (year > now.year + 20) return AppLocale.l10n.cardCheckYear;
  return null;
}

String? validateCvc(String raw, CardBrand brand) {
  final d = digitsOnly(raw);
  if (d.length != brand.cvcLength || d.length != raw.trim().length) {
    return AppLocale.l10n.cardCvcDigits(brand.cvcLength.toString());
  }
  return null;
}

/// A payment card as the app keeps it: brand and last four digits only.
/// The full number never leaves the checkout form's memory.
@immutable
class SavedCard {
  const SavedCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.token,
  });

  final String id;
  final CardBrand brand;
  final String last4;
  final int expMonth;
  final int expYear;

  /// Opaque gateway token standing in for the card.
  final String token;

  String get label => '${brand.label} •••• $last4';
  String get expiry =>
      '${expMonth.toString().padLeft(2, '0')}/'
      '${(expYear % 100).toString().padLeft(2, '0')}';
}

/// Demo wallet every account starts with (no real card data).
const kDemoCards = <SavedCard>[
  SavedCard(
    id: 'card_visa',
    brand: CardBrand.visa,
    last4: '4242',
    expMonth: 12,
    expYear: 2029,
    token: 'tok_visa',
  ),
  SavedCard(
    id: 'card_mc',
    brand: CardBrand.mastercard,
    last4: '4444',
    expMonth: 8,
    expYear: 2030,
    token: 'tok_mastercard_3ds',
  ),
];
