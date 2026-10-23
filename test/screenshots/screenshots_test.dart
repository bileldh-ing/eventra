@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:eventra/core/crypto/pbkdf2.dart';
import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/organizer/presentation/organizer_providers.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:eventra/features/tickets/domain/qr_token.dart';
import 'package:eventra/features/tickets/presentation/booking_success_screen.dart';
import 'package:eventra/features/tickets/presentation/ticket_detail_screen.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticket_visuals.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/golden.dart';
import '../helpers/harness.dart';
import '../helpers/map_tiles.dart';
import '../helpers/seed.dart';

/// Renders every key screen at 1170x2532 (390x844 @3x) with the real app
/// widgets, seed data, bundled fonts and fixture images, and writes PNGs to
/// docs/screenshots/. Not a regression test: run on demand with
///   flutter test --tags screenshots test/screenshots -j 1
/// (excluded from CI by its tag).
const _highland = 'evt-001-highland-music-festival';
const _past = 'evt-p04-late-laughs-showcase';
final GlobalKey _boundary = GlobalKey();

MemoryPrefsStore _prefs({
  String? theme,
  String? language,
  bool organizer = false,
  bool onboardingSeen = true,
}) => MemoryPrefsStore({
  'onboarding.seen': onboardingSeen,
  'interests.u_demo': ['music', 'tech', 'food'],
  SettingsKeys.themeMode: ?theme,
  SettingsKeys.language: ?language,
  if (organizer) organizerModeKey('u_demo'): true,
});

Future<void> _open(
  WidgetTester tester,
  TestApp app,
  String location, {
  bool tiles = false,
}) async {
  await setPhoneSize(tester);
  // iPhone-style safe areas (status bar and home indicator), so the device
  // frame's status bar and island sit over empty space as on a real phone.
  tester.view
    ..padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3)
    ..viewPadding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: app.build(initialLocation: location),
    ),
  );
  if (tiles) await precacheFixtureTiles(tester);
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester, [int frames = 20]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await _settle(tester, 6);
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String name) async {
  await precacheVisibleImages(tester);
  await tester.pumpAndSettle();
  final boundary =
      _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  File('docs/screenshots/$name.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
}

void _shot(String name, Future<void> Function(WidgetTester) body) {
  testWidgets('screenshot $name', (tester) async {
    await withRealShadows(() async {
      await body(tester);
      await _capture(tester, name);
    });
  });
}

/// Picker with 2 GA tickets, then checkout with the EVENTRA10 promo.
Future<TestApp> _toCheckout(WidgetTester tester) async {
  final app = TestApp();
  await _open(tester, app, '/home/event/$_highland/tickets');
  await _tapKey(tester, 'tier-ga-plus');
  await _tapKey(tester, 'tier-ga-plus');
  await _tapKey(tester, 'tier-continue');
  await tester.enterText(
    find.byKey(const ValueKey('promo-field')),
    'EVENTRA10',
  );
  await _tapKey(tester, 'promo-apply');
  FocusManager.instance.primaryFocus?.unfocus();
  await _settle(tester, 6);
  return app;
}

Future<void> _toSuccess(WidgetTester tester) async {
  await _toCheckout(tester);
  await _tapKey(tester, 'pay-button');
  await _pumpUntil(tester, find.byType(BookingSuccessScreen));
}

void main() {
  tearDown(() => AppLocale.set(const Locale('en')));

  _shot('01_onboarding', (t) async {
    await _open(
      t,
      TestApp(
        auth: const AuthState.signedOut(),
        prefs: _prefs(onboardingSeen: false),
      ),
      '/onboarding',
    );
  });

  _shot('02_login', (t) async {
    await _open(t, TestApp(auth: const AuthState.signedOut()), '/auth/login');
  });

  _shot('03_home_light', (t) async {
    await _open(t, TestApp(prefs: _prefs()), '/home');
  });

  _shot('04_home_dark', (t) async {
    await _open(t, TestApp(prefs: _prefs(theme: 'dark')), '/home');
  });

  _shot('05_home_arabic_rtl', (t) async {
    await _open(t, TestApp(prefs: _prefs(language: 'ar')), '/home');
  });

  _shot('06_explore_map', (t) async {
    await _open(t, TestApp(), '/explore', tiles: true);
  });

  _shot('07_search_results', (t) async {
    await _open(t, TestApp(), '/home/search');
    await t.enterText(find.byKey(const ValueKey('search-input')), 'music');
    await t.pump(const Duration(milliseconds: 300));
    FocusManager.instance.primaryFocus?.unfocus();
    await _settle(t);
  });

  _shot('08_filters', (t) async {
    await _open(t, TestApp(), '/home/search');
    await _tapKey(t, 'search-filter');
    await _settle(t);
  });

  _shot('09_event_details', (t) async {
    await _open(t, TestApp(), '/home/event/$_highland', tiles: true);
  });

  _shot('10_reviews', (t) async {
    await _open(t, TestApp(), '/home/event/$_past/reviews');
  });

  _shot('11_ticket_picker', (t) async {
    await _open(t, TestApp(), '/home/event/$_highland/tickets');
    await _tapKey(t, 'tier-ga-plus');
    await _tapKey(t, 'tier-ga-plus');
    await t.drag(find.byType(Scrollable).first, const Offset(0, 800));
    await _settle(t, 6);
  });

  _shot('12_checkout', (t) async {
    await _toCheckout(t);
  });

  _shot('13_booking_success', (t) async {
    await _toSuccess(t);
  });

  _shot('14_ticket_qr', (t) async {
    await _toSuccess(t);
    await _tapKey(t, 'view-ticket');
    await t.tap(find.byType(WalletTicketCard).first);
    await _pumpUntil(t, find.byType(TicketDetailScreen));
    await _settle(t);
  });

  _shot('15_favorites', (t) async {
    final ids = loadSeed().events
        .where((e) => e.startAt.isAfter(kTestNow))
        .take(5)
        .map((e) => e.id);
    await _open(
      t,
      TestApp(favorites: FakeFavoritesRepository()..ids.addAll(ids)),
      '/favorites',
    );
  });

  _shot('16_notifications', (t) async {
    await _open(t, TestApp(), '/home/notifications');
  });

  _shot('17_profile', (t) async {
    final ids = loadSeed().events.take(3).map((e) => e.id);
    await _open(
      t,
      TestApp(favorites: FakeFavoritesRepository()..ids.addAll(ids)),
      '/profile',
    );
  });

  _shot('18_settings', (t) async {
    await _open(t, TestApp(), '/profile/settings');
  });

  _shot('19_organizer_dashboard', (t) async {
    await _open(
      t,
      TestApp(prefs: _prefs(organizer: true)),
      '/organizer/dashboard',
    );
  });

  _shot('20_event_wizard', (t) async {
    await _open(
      t,
      TestApp(prefs: _prefs(organizer: true)),
      '/organizer/events/new',
    );
    await t.enterText(
      find.byKey(const ValueKey('wiz-title')),
      'Sousse Sunset Sessions',
    );
    await _tapKey(t, 'wiz-cat-music');
    await t.enterText(
      find.byKey(const ValueKey('wiz-description')),
      'An open-air evening of live electronic music by the sea, '
      'with local DJs, food trucks and a sunset view.',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await _settle(t);
  });

  _shot('21_checkin_result', (t) async {
    final app = TestApp(prefs: _prefs(organizer: true));
    await _open(t, app, '/organizer/events/$_highland/check-in');
    final qr = QrTokenService(
      decodeBase64UrlNoPad(app.secure.values[kQrKeyStorageKey]!),
    );
    app.scanner.emit(
      qr.payload(
        ticketId: 'tkt_g_${_highland}_1',
        eventId: _highland,
        holderId: 'guest-1',
        now: kTestNow,
      ),
    );
    await _settle(t, 30);
  });
}
