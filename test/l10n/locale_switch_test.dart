import 'package:eventra/app/app.dart';
import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

TextDirection _direction(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold).first));

Future<void> _pickLanguage(WidgetTester tester, String code) async {
  final tile = find.byKey(ValueKey('language-$code'));
  await tester.scrollUntilVisible(
    tile,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => AppLocale.set(const Locale('en')));

  testWidgets('switching language relabels the app and flips to RTL', (
    tester,
  ) async {
    await setPhoneSize(tester);
    final prefs = MemoryPrefsStore({
      'onboarding.seen': true,
      'interests.u_demo': ['music', 'tech', 'food'],
    });
    await tester.pumpWidget(
      TestApp(prefs: prefs).build(initialLocation: '/profile/settings'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(_direction(tester), TextDirection.ltr);

    await _pickLanguage(tester, 'fr');
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('APPARENCE'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);
    expect(_direction(tester), TextDirection.ltr);
    expect(prefs.getString(SettingsKeys.language), 'fr');
    // Pure-Dart formatters follow the same locale.
    expect(formatPrice(0), 'Gratuit');

    await _pickLanguage(tester, 'ar');
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(_direction(tester), TextDirection.rtl);
    expect(prefs.getString(SettingsKeys.language), 'ar');
    expect(formatPrice(0), 'مجاني');
    final material = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(material.locale, const Locale('ar'));

    await _pickLanguage(tester, 'en');
    expect(find.text('Settings'), findsOneWidget);
    expect(_direction(tester), TextDirection.ltr);
    expect(formatPrice(0), 'Free');
  });

  testWidgets('a saved language is applied on launch, nav pill mirrored', (
    tester,
  ) async {
    await setPhoneSize(tester);
    final prefs = MemoryPrefsStore({
      'onboarding.seen': true,
      'interests.u_demo': ['music', 'tech', 'food'],
      SettingsKeys.language: 'ar',
    });
    await tester.pumpWidget(TestApp(prefs: prefs).build());
    await tester.pumpAndSettle();

    expect(find.byType(EventraApp), findsOneWidget);
    expect(_direction(tester), TextDirection.rtl);
    expect(find.text('الرئيسية'), findsOneWidget); // Active "Home" tab.
    // Home is the first tab, so in RTL it sits at the right of the pill.
    final home = tester.getCenter(find.byKey(const ValueKey('nav-Home')));
    final profile = tester.getCenter(
      find.byKey(const ValueKey('nav-Profile')),
    );
    expect(home.dx, greaterThan(profile.dx));
    expect(find.text('الفعاليات القادمة'), findsOneWidget);
  });

  testWidgets('French formats dates, times and money for France', (
    tester,
  ) async {
    AppLocale.set(const Locale('fr'));
    final d = DateTime(2026, 10, 24, 21, 30);
    expect(formatTime(d), '21:30');
    expect(formatMonthDay(d), '24 oct.');
    expect(formatDecimal(2.5), '2,5');
    AppLocale.set(const Locale('en'));
    expect(formatTime(d), '9:30 PM');
    expect(formatMonthDay(d), 'Oct 24');
  });
}
