import 'package:eventra/app/nav_pill.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/login_screen.dart';
import 'package:eventra/features/onboarding/presentation/interests_screen.dart';
import 'package:eventra/features/onboarding/presentation/location_setup_screen.dart';
import 'package:eventra/features/onboarding/presentation/onboarding_screen.dart';
import 'package:eventra/features/onboarding/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Interests (3 picks) then a city, as a first-time user does.
Future<void> finishSetup(WidgetTester tester) async {
  expect(find.byType(InterestsScreen), findsOneWidget);
  await tapKey(tester, 'interest-music');
  await tapKey(tester, 'interest-tech');
  expect(find.text('Choose 1 more'), findsOneWidget);
  await tapKey(tester, 'interest-food');
  expect(find.text('3 selected'), findsOneWidget);
  await tapKey(tester, 'interests-continue');
  expect(find.byType(LocationSetupScreen), findsOneWidget);
  await tapKey(tester, 'city-Nyack');
  await tapKey(tester, 'location-continue');
}

void main() {
  testWidgets('first launch: splash, 3 onboarding slides, then login', (
    tester,
  ) async {
    await setPhoneSize(tester);
    final app = TestApp(restore: true, onboardingSeen: false);
    await tester.pumpWidget(app.build(initialLocation: '/splash'));
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Discover. Book. Feel the moment.'), findsOneWidget);
    await tester.pump(SplashScreen.minimumShow);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Discover events near you'), findsOneWidget);
    await tapKey(tester, 'onboarding-next');
    expect(find.text('Book in seconds'), findsOneWidget);
    await tapKey(tester, 'onboarding-next');
    expect(find.text('Enter with a tap'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    await tapKey(tester, 'onboarding-next');

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(app.prefs.values['onboarding.seen'], isTrue);
  });

  testWidgets('demo login, interests (min 3), city, Home; relaunch keeps '
      'the session', (tester) async {
    await setPhoneSize(tester);
    final db = memoryDb();
    addTearDown(db.close);
    final first = TestApp(auth: const AuthState.signedOut(), db: db);
    await tester.pumpWidget(first.build());
    await tester.pumpAndSettle();
    // Signed-out users are sent to log in.
    expect(find.byType(LoginScreen), findsOneWidget);
    await tapKey(tester, 'login-demo');
    await finishSetup(tester);
    expect(find.byType(NavPill), findsOneWidget);
    expect(first.prefs.values['location.homeCity'], startsWith('Nyack|NY'));
    expect(first.secure.values, isNotEmpty);

    // Relaunch over the same database, keychain and prefs.
    await tester.pumpWidget(const SizedBox());
    final second = TestApp(
      restore: true,
      secure: first.secure,
      prefs: first.prefs,
      db: db,
    );
    await tester.pumpWidget(second.build(initialLocation: '/splash'));
    await tester.pump(SplashScreen.minimumShow);
    await tester.pumpAndSettle();
    expect(find.byType(NavPill), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('validation errors, then 5 bad attempts lock with countdown', (
    tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      TestApp(
        auth: const AuthState.signedOut(),
      ).build(initialLocation: '/auth/login'),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'login-submit');
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'ada@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'wrong-password',
    );
    for (var i = 1; i < kMaxFailedAttempts; i++) {
      await tapKey(tester, 'login-submit');
    }
    expect(find.textContaining('1 attempt left'), findsOneWidget);
    await tapKey(tester, 'login-submit');
    expect(find.textContaining('Too many attempts'), findsOneWidget);
    expect(find.text('Try again in 30s'), findsOneWidget);
    // The countdown ticker keeps the button disabled (the test clock is
    // frozen, so it stays at 30s).
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Try again in 30s'), findsOneWidget);
    final button = tester.widget<GradientPillButton>(
      find.byKey(const ValueKey('login-submit')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('guest hitting Get a Ticket logs in and returns to tickets', (
    tester,
  ) async {
    await setPhoneSize(tester);
    final id = loadSeed().events.first.id;
    await tester.pumpWidget(
      TestApp(
        auth: const AuthState.guest(),
      ).build(initialLocation: '/home/event/$id/tickets'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Log in to continue where you left off.'), findsOneWidget);
    await tapKey(tester, 'login-demo');
    await finishSetup(tester);
    expect(find.text('Get a Ticket'), findsWidgets);
  });

  testWidgets('sign up with strength meter, OTP 123456, then interests', (
    tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      TestApp(
        auth: const AuthState.signedOut(),
      ).build(initialLocation: '/auth/login'),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'login-signup');
    expect(find.text('Create account'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('signup-name')),
      'Ada Lovelace',
    );
    await tester.enterText(
      find.byKey(const ValueKey('signup-email')),
      'ada@example.com',
    );
    await tester.enterText(find.byKey(const ValueKey('signup-password')), 'ab');
    await tester.pumpAndSettle();
    expect(find.text('Weak'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('signup-password')),
      'Sunset#Rooftop7',
    );
    await tester.pumpAndSettle();
    expect(find.text('Strong'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('signup-confirm')),
      'Sunset#Rooftop7',
    );
    // Terms not accepted yet: nothing is created.
    await tapKey(tester, 'signup-submit');
    expect(find.text('Create account'), findsOneWidget);
    await tapKey(tester, 'signup-terms');
    await tapKey(tester, 'signup-submit');

    expect(find.text('Check your email'), findsOneWidget);
    expect(find.byKey(const ValueKey('otp-demo-hint')), findsOneWidget);
    expect(find.text('Resend in 0:30'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('otp-input')), '000000');
    await tester.pumpAndSettle();
    expect(find.textContaining('code is not right'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('otp-input')), '123456');
    await tester.pumpAndSettle();
    expect(find.byType(InterestsScreen), findsOneWidget);
  });

  testWidgets('profile shows the user and logs out; guests get Log in', (
    tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(TestApp().build(initialLocation: '/profile'));
    await tester.pumpAndSettle();
    expect(find.text(kDemoName), findsOneWidget);
    expect(find.text(kDemoEmail), findsOneWidget);
    await tapKey(tester, 'profile-Log out');
    await tester.tap(find.byKey(const ValueKey('logout-confirm')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tapKey(tester, 'login-guest');
    // Guests have no interests yet.
    await finishSetup(tester);
    await tester.tap(find.byKey(const ValueKey('nav-Profile')));
    await tester.pumpAndSettle();
    expect(find.text('Guest'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-login')), findsOneWidget);
  });
}
