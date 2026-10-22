import 'dart:io';

import 'package:eventra/core/app_info.dart';
import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/notifications/presentation/notifications_providers.dart';
import 'package:eventra/features/settings/domain/app_settings.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:eventra/features/settings/presentation/settings_screen.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

Future<void> reveal(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
}

void main() {
  final highland = loadSeed().events.firstWhere(
    (e) => e.id == 'evt-001-highland-music-festival',
  );

  ProviderContainer containerFor(TestApp app) {
    final c = ProviderContainer(overrides: app.overrides);
    addTearDown(c.dispose);
    return c;
  }

  group('settings persistence', () {
    test('defaults when nothing is stored', () {
      final c = containerFor(TestApp());
      expect(c.read(settingsProvider), const AppSettings());
      expect(c.read(settingsProvider).themeMode, ThemeMode.system);
      expect(c.read(settingsProvider).language, AppLanguage.en);
    });

    test('changes survive a relaunch', () async {
      final prefs = MemoryPrefsStore();
      final c = containerFor(TestApp(prefs: prefs));
      final s = c.read(settingsProvider.notifier);
      await s.setThemeMode(ThemeMode.dark);
      await s.setLanguage(AppLanguage.ar);
      await s.setEventReminders(value: false);
      await s.setOrderUpdates(value: false);
      await s.setRecommendations(value: false);
      await s.setPersonalizedFeed(value: false);

      final relaunched = containerFor(TestApp(prefs: prefs));
      expect(
        relaunched.read(settingsProvider),
        const AppSettings(
          themeMode: ThemeMode.dark,
          language: AppLanguage.ar,
          eventReminders: false,
          orderUpdates: false,
          recommendations: false,
          personalizedFeed: false,
        ),
      );
      expect(prefs.values[SettingsKeys.language], 'ar');
    });

    test('corrupt values fall back to defaults', () {
      final c = containerFor(
        TestApp(
          prefs: MemoryPrefsStore({
            SettingsKeys.themeMode: 'neon',
            SettingsKeys.language: 'xx',
          }),
        ),
      );
      expect(c.read(settingsProvider).themeMode, ThemeMode.system);
      expect(c.read(settingsProvider).language, AppLanguage.en);
    });

    test('app version matches pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('version: $kAppVersion+$kAppBuild'));
    });
  });

  group('notification toggles gate real behavior', () {
    Future<Order> buy(ProviderContainer c) async {
      final actions = c.read(ticketingActionsProvider);
      final hold = (await actions.hold(
        userId: 'u_demo',
        event: highland,
        quantities: {'ga': 1},
      )).valueOrNull!;
      final r = await actions.pay(
        CheckoutRequest(
          holdId: hold.id,
          userId: 'u_demo',
          event: highland,
          attendeeName: 'Daniel Brooks',
          attendeeEmail: 'demo@eventra.app',
          idempotencyKey: 'k-${hold.id}',
          method: SavedCardMethod(kDemoCards.first),
        ),
      );
      return r.valueOrNull!;
    }

    test('reminders on: orders schedule them', () async {
      final app = TestApp();
      final c = containerFor(app);
      final order = await buy(c);
      expect(app.reminders.scheduled[order.id], hasLength(2));
    });

    test('reminders off: nothing is scheduled; toggling cancels and '
        'reschedules existing orders', () async {
      final app = TestApp();
      final c = containerFor(app);
      final first = await buy(c);
      await c.read(settingsProvider.notifier).setEventReminders(value: false);
      await c
          .read(ticketingActionsProvider)
          .applyReminderSetting(userId: 'u_demo', enabled: false);
      expect(app.reminders.scheduled, isEmpty);
      expect(app.reminders.cancelled, contains(first.id));

      final second = await buy(c);
      expect(app.reminders.scheduled.containsKey(second.id), isFalse);

      await c.read(settingsProvider.notifier).setEventReminders(value: true);
      await c
          .read(ticketingActionsProvider)
          .applyReminderSetting(userId: 'u_demo', enabled: true);
      expect(app.reminders.scheduled.keys, containsAll([first.id, second.id]));
    });

    test('order updates add inbox items on purchase and refund', () async {
      final c = containerFor(TestApp());
      final order = await buy(c);
      final repo = c.read(notificationsRepositoryProvider);
      var inbox = await repo.list('u_demo');
      final confirmed = inbox.firstWhere(
        (n) => n.kind == NotificationKind.orderConfirmed,
      );
      expect(confirmed.ticketId, order.tickets.first.id);
      expect(confirmed.read, isFalse);

      await c.read(ticketingActionsProvider).refund(order.id, userId: 'u_demo');
      inbox = await repo.list('u_demo');
      expect(inbox.first.kind, NotificationKind.refund);
    });

    test('order updates off: no inbox items', () async {
      final c = containerFor(TestApp());
      await c.read(settingsProvider.notifier).setOrderUpdates(value: false);
      await buy(c);
      final inbox = await c
          .read(notificationsRepositoryProvider)
          .list('u_demo');
      expect(
        inbox.where((n) => n.kind == NotificationKind.orderConfirmed),
        isEmpty,
      );
    });
  });

  group('settings screen', () {
    testWidgets('theme mode is wired to MaterialApp and persisted', (
      tester,
    ) async {
      await setPhoneSize(tester);
      final app = TestApp();
      await tester.pumpWidget(app.build(initialLocation: '/profile/settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      MaterialApp material() =>
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(material().themeMode, ThemeMode.system);
      expect(material().darkTheme, isNotNull);

      await tester.tap(find.byKey(const ValueKey('theme-dark')));
      await tester.pumpAndSettle();
      expect(material().themeMode, ThemeMode.dark);
      expect(app.prefs.values[SettingsKeys.themeMode], 'dark');

      await tester.tap(find.byKey(const ValueKey('language-fr')));
      await tester.pumpAndSettle();
      expect(app.prefs.values[SettingsKeys.language], 'fr');

      await reveal(tester, 'setting-recommendations');
      await tester.tap(find.byKey(const ValueKey('setting-recommendations')));
      await tester.pumpAndSettle();
      expect(app.prefs.values[SettingsKeys.recommendations], isFalse);

      await reveal(tester, 'app-version');
      expect(find.text('v$kAppVersion ($kAppBuild)'), findsOneWidget);
    });

    testWidgets('recommendations off hides those inbox items', (tester) async {
      await setPhoneSize(tester);
      final app = TestApp(
        prefs: MemoryPrefsStore({
          'onboarding.seen': true,
          SettingsKeys.recommendations: false,
        }),
      );
      await tester.pumpWidget(
        app.build(initialLocation: '/profile/notifications'),
      );
      await tester.pumpAndSettle();
      expect(find.text('2 friends are going'), findsOneWidget);
      expect(find.text('Early Bird price available'), findsNothing);
    });

    testWidgets('clear cache confirms; delete account needs DELETE', (
      tester,
    ) async {
      await setPhoneSize(tester);
      final app = TestApp();
      await tester.pumpWidget(app.build(initialLocation: '/profile/settings'));
      await tester.pumpAndSettle();
      await reveal(tester, 'setting-clear-cache');
      await tester.tap(find.byKey(const ValueKey('setting-clear-cache')));
      await tester.pumpAndSettle();
      expect(find.text('Cache cleared'), findsOneWidget);

      await reveal(tester, 'setting-delete-account');
      await tester.tap(find.byKey(const ValueKey('setting-delete-account')));
      await tester.pumpAndSettle();
      final confirm = find.byKey(const ValueKey('delete-account-confirm'));
      expect(tester.widget<TextButton>(confirm).onPressed, isNull);
      await tester.enterText(
        find.byKey(const ValueKey('delete-confirm-text')),
        'delete',
      );
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(container.read(authControllerProvider).isSignedIn, isFalse);
    });
  });
}
