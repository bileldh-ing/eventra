import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import '../helpers/map_tiles.dart';

/// Every main screen lays out without overflow or exceptions in French
/// (longest strings) and Arabic (RTL), in light and dark mode.
void main() {
  tearDown(() => AppLocale.set(const Locale('en')));

  const routes = [
    '/home',
    '/home/all',
    '/explore',
    '/favorites',
    '/tickets',
    '/profile',
    '/profile/settings',
    '/profile/notifications',
    '/home/event/evt-002-pitchfork-music-night',
    '/home/event/evt-002-pitchfork-music-night/tickets',
  ];

  for (final (language, theme) in [
    ('fr', 'light'),
    ('ar', 'light'),
    ('ar', 'dark'),
  ]) {
    for (final route in routes) {
      testWidgets('$route renders cleanly in $language/$theme', (tester) async {
        await setPhoneSize(tester);
        final prefs = MemoryPrefsStore({
          'onboarding.seen': true,
          'interests.u_demo': ['music', 'tech', 'food'],
          SettingsKeys.language: language,
          SettingsKeys.themeMode: theme,
        });
        await tester.pumpWidget(
          TestApp(prefs: prefs).build(initialLocation: route),
        );
        if (route == '/explore') await precacheFixtureTiles(tester);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final dir = Directionality.of(
          tester.element(find.byType(Scaffold).first),
        );
        expect(
          dir,
          language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
      });
    }
  }
}
