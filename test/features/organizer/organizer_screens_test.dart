import 'package:eventra/app/app.dart';
import 'package:eventra/app/auth_guard.dart';
import 'package:eventra/core/crypto/pbkdf2.dart';
import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/organizer/data/organizer_repository.dart';
import 'package:eventra/features/organizer/domain/check_in.dart';
import 'package:eventra/features/organizer/domain/event_draft.dart';
import 'package:eventra/features/organizer/presentation/check_in_screen.dart';
import 'package:eventra/features/organizer/presentation/event_wizard_screen.dart';
import 'package:eventra/features/organizer/presentation/organizer_dashboard_screen.dart';
import 'package:eventra/features/organizer/presentation/organizer_providers.dart';
import 'package:eventra/features/organizer/presentation/widgets/scan_result_sheet.dart';
import 'package:eventra/features/tickets/domain/qr_token.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/golden.dart';
import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

const _pulseEvent = 'evt-001-highland-music-festival';

MemoryPrefsStore organizerPrefs({bool on = true}) => MemoryPrefsStore({
  'onboarding.seen': true,
  'interests.u_demo': ['music', 'tech', 'food'],
  organizerModeKey('u_demo'): on,
});

QrTokenService testQr(TestApp app) => QrTokenService(
  decodeBase64UrlNoPad(app.secure.values[kQrKeyStorageKey]!),
);

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(EventraApp)));

Future<void> settle(WidgetTester tester, [int frames = 30]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Widget themed(Widget child, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      theme: buildEventraTheme(),
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Align(alignment: Alignment.bottomCenter, child: child),
      ),
    );

void main() {
  group('route guard', () {
    final user = AppUser(
      id: 'u1',
      name: 'Ada',
      email: 'ada@example.com',
      verified: true,
      createdAt: DateTime(2026),
    );
    String? go(String path, AuthState auth, {bool organizer = false}) =>
        authRedirect(
          auth: auth,
          onboardingSeen: true,
          organizerMode: organizer,
          uri: Uri.parse(path),
        );

    test('organizer pages need an account and organizer mode', () {
      final inside = AuthState.signedIn(user);
      expect(
        Uri.parse(go('/organizer/dashboard', const AuthState.guest())!).path,
        '/auth/login',
      );
      expect(go('/organizer/dashboard', inside), '/profile');
      expect(go('/organizer/events/e1/check-in', inside), '/profile');
      expect(go('/organizer/dashboard', inside, organizer: true), isNull);
      expect(go('/organizers-guide', inside), isNull);
    });
  });

  group('scan result card', () {
    Future<void> pumpResult(WidgetTester tester, CheckInResult r) async {
      await tester.pumpWidget(themed(ScanResultCard(result: r)));
      await tester.pumpAndSettle();
    }

    Color iconColor(WidgetTester tester) {
      final box = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(Icon).first,
              matching: find.byType(Container),
            )
            .first,
      );
      return (box.decoration! as BoxDecoration).color!;
    }

    testWidgets('each outcome has its own color and message', (tester) async {
      const t = EventraTokens.light;
      final cases = <CheckInResult, (String, Color)>{
        CheckInResult(
          CheckInOutcome.valid,
          holderName: 'Amira Ben Salah',
          tierName: 'VIP',
          checkedInAt: DateTime(2026, 11, 2, 19, 30),
        ): (
          'Valid ticket. Welcome!',
          t.success,
        ),
        CheckInResult(
          CheckInOutcome.alreadyCheckedIn,
          holderName: 'Lucas Martin',
          tierName: 'GA',
          checkedInAt: DateTime(2026, 11, 2, 19, 5),
        ): (
          'Already checked in',
          t.accentOrange,
        ),
        const CheckInResult(CheckInOutcome.wrongEvent): (
          'Wrong event',
          t.error,
        ),
        const CheckInResult(
          CheckInOutcome.invalid,
          reason: InvalidReason.expired,
        ): (
          'Code expired',
          t.error,
        ),
        const CheckInResult(
          CheckInOutcome.invalid,
          reason: InvalidReason.forged,
        ): (
          'Invalid ticket',
          t.error,
        ),
        const CheckInResult(CheckInOutcome.cancelled, holderName: 'Omar'): (
          'Cancelled',
          t.textSecondary,
        ),
      };
      for (final MapEntry(key: r, value: (title, color)) in cases.entries) {
        await pumpResult(tester, r);
        expect(
          find.byKey(ValueKey('scan-result-${r.outcome.name}')),
          findsOneWidget,
        );
        expect(find.text(title), findsOneWidget);
        expect(iconColor(tester), color, reason: title);
      }
      // Holder, tier and the first check-in time are shown.
      await pumpResult(tester, cases.keys.elementAt(1));
      expect(find.text('Lucas Martin'), findsOneWidget);
      expect(find.text('This ticket was used at 7:05 PM.'), findsOneWidget);
    });

    testWidgets('French and Arabic copy', (tester) async {
      const r = CheckInResult(CheckInOutcome.wrongEvent);
      await tester.pumpWidget(
        themed(const ScanResultCard(result: r), locale: const Locale('fr')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mauvais événement'), findsOneWidget);
      await tester.pumpWidget(
        themed(const ScanResultCard(result: r), locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();
      expect(find.text('فعالية خاطئة'), findsOneWidget);
    });
  });

  group('organizer mode', () {
    testWidgets('the Profile switch opens the dashboard and persists', (
      tester,
    ) async {
      await setPhoneSize(tester);
      final app = TestApp();
      await tester.pumpWidget(app.build(initialLocation: '/profile'));
      await settle(tester);
      expect(find.byKey(const ValueKey('organizer-switch')), findsOneWidget);
      await tapKey(tester, 'organizer-switch');
      await settle(tester);
      expect(find.byType(OrganizerDashboardScreen), findsOneWidget);
      expect(app.prefs.getBool(organizerModeKey('u_demo')), isTrue);
      expect(find.byKey(const ValueKey('stat-revenue')), findsOneWidget);
      expect(find.byKey(const ValueKey('stat-sold')), findsOneWidget);
      expect(find.byKey(const ValueKey('stat-checkin')), findsOneWidget);
      expect(find.byKey(const ValueKey('org-sales-chart')), findsOneWidget);
      // The demo organizer's seeded events are listed.
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('org-event-$_pulseEvent')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const ValueKey('org-event-$_pulseEvent')),
        findsOneWidget,
      );
    });

    testWidgets('a deep link to the dashboard without the mode goes to '
        'Profile', (tester) async {
      await setPhoneSize(tester);
      final app = TestApp();
      await tester.pumpWidget(
        app.build(initialLocation: '/organizer/dashboard'),
      );
      await settle(tester);
      expect(find.byType(OrganizerDashboardScreen), findsNothing);
      expect(find.byKey(const ValueKey('organizer-switch')), findsOneWidget);
    });
  });

  group('check-in screen', () {
    testWidgets('scan, duplicate, manual entry and guest list', (tester) async {
      await setPhoneSize(tester);
      final app = TestApp(prefs: organizerPrefs());
      await tester.pumpWidget(
        app.build(initialLocation: '/organizer/events/$_pulseEvent/check-in'),
      );
      await settle(tester);
      expect(find.byType(CheckInScreen), findsOneWidget);
      expect(find.text('0 of 12 checked in'), findsOneWidget);

      final qr = testQr(app);
      final code = qr.payload(
        ticketId: 'tkt_g_${_pulseEvent}_1',
        eventId: _pulseEvent,
        holderId: 'guest-1',
        now: kTestNow,
      );
      app.scanner.emit(code);
      await settle(tester);
      expect(find.byKey(const ValueKey('scan-result-valid')), findsOneWidget);
      await tapKey(tester, 'scan-next');
      await settle(tester);
      expect(find.text('1 of 12 checked in'), findsOneWidget);

      // The same ticket typed in by hand is already used.
      await tapKey(tester, 'enter-code');
      await tester.enterText(
        find.byKey(const ValueKey('manual-code')),
        'tkt_g_${_pulseEvent}_1',
      );
      await tapKey(tester, 'manual-submit');
      await settle(tester);
      expect(
        find.byKey(const ValueKey('scan-result-alreadyCheckedIn')),
        findsOneWidget,
      );
      await tapKey(tester, 'scan-next');

      // A forged code.
      app.scanner.emit('ETK1.x.$_pulseEvent.y.1.zzz');
      await settle(tester);
      expect(find.byKey(const ValueKey('scan-result-invalid')), findsOneWidget);
      await tapKey(tester, 'scan-next');

      // Guest list: search and manual check-in.
      await tapKey(tester, 'tab-list');
      final second = find.byKey(
        const ValueKey('guest-checkin-tkt_g_${_pulseEvent}_2'),
      );
      expect(second, findsOneWidget);
      await tester.tap(second);
      await settle(tester);
      expect(find.byKey(const ValueKey('scan-result-valid')), findsOneWidget);
      await tapKey(tester, 'scan-next');
      await settle(tester);
      expect(find.text('2 of 12 checked in'), findsOneWidget);
      expect(second, findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('guest-search')),
        'zzz-nobody',
      );
      await tester.pumpAndSettle();
      expect(find.text('No guest matches your search.'), findsOneWidget);
    });

    testWidgets('without a camera the typed-code fallback is offered', (
      tester,
    ) async {
      await setPhoneSize(tester);
      final app = TestApp(prefs: organizerPrefs());
      await tester.pumpWidget(
        app.build(initialLocation: '/organizer/events/$_pulseEvent/check-in'),
      );
      await settle(tester);
      app.scanner.failCamera();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('camera-unavailable')), findsOneWidget);
      expect(find.byKey(const ValueKey('enter-code')), findsOneWidget);
    });
  });

  group('create-event wizard', () {
    testWidgets('validation blocks the first step', (tester) async {
      await setPhoneSize(tester);
      final app = TestApp(prefs: organizerPrefs());
      await tester.pumpWidget(
        app.build(initialLocation: '/organizer/events/new'),
      );
      await settle(tester);
      expect(find.byKey(const ValueKey('wiz-step-basics')), findsOneWidget);
      await tapKey(tester, 'wiz-next');
      expect(find.byKey(const ValueKey('wiz-step-basics')), findsOneWidget);
      expect(find.text('Use 3 to 80 characters.'), findsOneWidget);
      expect(find.text('Pick a category.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('wiz-title')),
        'Rooftop Jazz Session',
      );
      await tapKey(tester, 'wiz-cat-music');
      await tester.enterText(
        find.byKey(const ValueKey('wiz-description')),
        'An evening of live jazz with a view over the old town.',
      );
      await tapKey(tester, 'wiz-next');
      expect(find.byKey(const ValueKey('wiz-step-schedule')), findsOneWidget);
      // The typed basics were autosaved as a draft.
      await tester.pump(const Duration(seconds: 1));
      await settle(tester, 10);
      final c = containerOf(tester);
      final user = c.read(organizerIdentityProvider);
      expect(user, isNotNull);
      final drafts = await tester.runAsync(
        () => c.read(organizerRepositoryProvider).drafts('u_demo'),
      );
      expect(drafts!.single.title, 'Rooftop Jazz Session');
      expect(drafts.single.category, EventCategory.music);
    });

    testWidgets('a resumed draft publishes into the attendee feed', (
      tester,
    ) async {
      await setPhoneSize(tester);
      final db = memoryDb();
      addTearDown(db.close);
      final app = TestApp(prefs: organizerPrefs(), db: db);
      await tester.runAsync(
        () => OrganizerRepository(db: db, clock: () => kTestNow).saveDraft(
          'u_demo',
          EventDraft(
            id: 'drf_resume',
            title: 'Harbor Night Market',
            category: EventCategory.food,
            description: 'Street food stalls, live bands and lanterns.',
            startAt: DateTime(2026, 11, 14, 19),
            endAt: DateTime(2026, 11, 14, 23),
            venue: 'Pier 3',
            address: '12 Quay Street',
            latitude: 40.75,
            longitude: -73.99,
            tiers: const [
              DraftTier(
                id: 'ga',
                name: 'General',
                priceCents: 1500,
                capacity: 300,
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(
        app.build(initialLocation: '/organizer/drafts/drf_resume'),
      );
      await settle(tester);
      for (final step in ['schedule', 'venue', 'tiers', 'cover']) {
        await tapKey(tester, 'wiz-next');
        expect(find.byKey(ValueKey('wiz-step-$step')), findsOneWidget);
      }
      // No cover yet: blocked.
      await tapKey(tester, 'wiz-next');
      expect(find.text('Pick a cover photo.'), findsOneWidget);
      await tapKey(tester, 'wiz-cover-2');
      await tapKey(tester, 'wiz-next');
      expect(find.byKey(const ValueKey('wiz-step-review')), findsOneWidget);
      expect(find.byKey(const ValueKey('wiz-review-problems')), findsNothing);
      await tapKey(tester, 'wiz-publish');
      await settle(tester, 60);
      expect(find.byType(EventWizardScreen), findsNothing);

      final c = containerOf(tester);
      final all = await tester.runAsync(() => c.read(eventsProvider.future));
      final mine = all!.where((e) => e.title == 'Harbor Night Market');
      expect(mine, hasLength(1));
      expect(mine.single.organizer.id, kDemoOrganizerId);
      expect(mine.single.coverImageUrl, kCoverChoices[2]);
      final drafts = await tester.runAsync(
        () => c.read(organizerRepositoryProvider).drafts('u_demo'),
      );
      expect(drafts, isEmpty);
      // It is bookable like any catalogue event.
      final stock = await tester.runAsync(
        () => c.read(ticketingRepositoryProvider).availability(mine.single),
      );
      expect(stock!.single.available, 300);
    });
  });

  testWidgets('dashboard golden', (tester) async {
    await withRealShadows(() async {
      await setPhoneSize(tester, dpr: 2);
      tester.view.physicalSize = const Size(390 * 2, 1300 * 2);
      final app = TestApp(prefs: organizerPrefs());
      await tester.pumpWidget(
        app.build(initialLocation: '/organizer/dashboard'),
      );
      await settle(tester);
      // Admit two guests so the check-in card is not empty.
      final c = containerOf(tester);
      await tester.runAsync(() async {
        await c.read(organizerEventsProvider.future);
        final repo = c.read(organizerRepositoryProvider);
        await repo.checkInTicket(
          'tkt_g_${_pulseEvent}_1',
          eventId: _pulseEvent,
        );
        await repo.checkInTicket(
          'tkt_g_${_pulseEvent}_2',
          eventId: _pulseEvent,
        );
      });
      c.read(organizerRevisionProvider.notifier).bump();
      await settle(tester);
      await precacheVisibleImages(tester);
      await tester.pumpAndSettle();
      await expectGolden(
        find.byType(OrganizerDashboardScreen),
        'goldens/dashboard.png',
      );
    });
  }, tags: ['golden']);
}
