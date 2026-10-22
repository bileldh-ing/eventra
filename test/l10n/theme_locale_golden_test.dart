@Tags(['golden'])
library;

import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';
import '../helpers/harness.dart';
import '../helpers/map_tiles.dart';

MemoryPrefsStore _prefs({String? theme, String? language}) => MemoryPrefsStore({
  'onboarding.seen': true,
  'interests.u_demo': ['music', 'tech', 'food'],
  SettingsKeys.themeMode: ?theme,
  SettingsKeys.language: ?language,
});

Future<void> _shoot(
  WidgetTester tester,
  MemoryPrefsStore prefs,
  String golden, {
  String initialLocation = '/home',
  bool tiles = false,
}) async {
  await setPhoneSize(tester, dpr: 2);
  await withRealShadows(() async {
    await tester.pumpWidget(
      TestApp(prefs: prefs).build(initialLocation: initialLocation),
    );
    if (tiles) await precacheFixtureTiles(tester);
    await tester.pumpAndSettle();
    await precacheVisibleImages(tester);
    await tester.pumpAndSettle();
    await expectGolden(find.byType(MaterialApp), golden);
  });
}

void main() {
  tearDown(() => AppLocale.set(const Locale('en')));

  testWidgets('Home in dark mode matches the golden', (tester) async {
    await _shoot(tester, _prefs(theme: 'dark'), 'goldens/home_dark.png');
  });

  testWidgets('Home in Arabic (RTL) matches the golden', (tester) async {
    await _shoot(tester, _prefs(language: 'ar'), 'goldens/home_ar.png');
  });

  testWidgets('Event Details in dark mode matches the golden', (tester) async {
    await _shoot(
      tester,
      _prefs(theme: 'dark'),
      'goldens/details_dark.png',
      initialLocation: '/home/event/evt-002-pitchfork-music-night',
      tiles: true,
    );
  });
}
