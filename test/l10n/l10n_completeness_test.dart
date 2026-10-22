import 'dart:convert';
import 'dart:io';

import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// Top-level `{name}` placeholders and plural/select variables of [message].
Set<String> _placeholders(String message) => {
  for (final m in RegExp(r'\{(\w+), (?:plural|select)').allMatches(message))
    m.group(1)!,
  for (final m in RegExp(r'(?<![\w=])\{(\w+)\}').allMatches(message))
    m.group(1)!,
};

void main() {
  final en = _arb('en');
  final fr = _arb('fr');
  final ar = _arb('ar');

  test('every locale has exactly the same keys', () {
    final base = _keys(en);
    expect(base.length, greaterThan(400));
    for (final (name, arb) in [('fr', fr), ('ar', ar)]) {
      final keys = _keys(arb);
      expect(base.difference(keys), isEmpty, reason: '$name is missing keys');
      expect(keys.difference(base), isEmpty, reason: '$name has extra keys');
    }
  });

  test('no message is empty and placeholders match English', () {
    for (final key in _keys(en)) {
      final expected = _placeholders(en[key] as String);
      for (final (name, arb) in [('en', en), ('fr', fr), ('ar', ar)]) {
        final value = arb[key] as String;
        expect(value.trim(), isNotEmpty, reason: '$name.$key is empty');
        expect(
          _placeholders(value),
          expected,
          reason: '$name.$key placeholders differ from English',
        );
      }
    }
  });

  test('French and Arabic are actually translated', () {
    // Brand names and symbols may legitimately match; the bulk may not.
    final same = _keys(en).where((k) => fr[k] == en[k]).length;
    expect(same / _keys(en).length, lessThan(0.08));
    final sameAr = _keys(en).where((k) => ar[k] == en[k]).length;
    expect(sameAr / _keys(en).length, lessThan(0.03));
  });

  test('plurals resolve per locale, including Arabic dual and few', () {
    final l = {
      for (final c in ['en', 'fr', 'ar']) c: lookupAppLocalizations(Locale(c)),
    };
    expect(l['en']!.nTickets(1), '1 ticket');
    expect(l['en']!.nTickets(3), '3 tickets');
    expect(l['fr']!.nTickets(0), contains('billet'));
    expect(l['fr']!.nTickets(2), '2 billets');
    expect(l['ar']!.nTickets(1), 'تذكرة واحدة');
    expect(l['ar']!.nTickets(2), 'تذكرتان');
    expect(l['ar']!.nTickets(5), '5 تذاكر');
    expect(l['ar']!.nTickets(11), '11 تذكرة');
  });

  test('the generated delegate supports exactly the shipped locales', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      kSupportedLocales.map((l) => l.languageCode).toSet(),
    );
  });
}
