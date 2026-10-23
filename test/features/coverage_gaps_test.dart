import 'package:eventra/core/utils/app_log.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/auth/presentation/forgot_password_screen.dart';
import 'package:eventra/features/auth/presentation/login_screen.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/widgets/share_event.dart';
import 'package:eventra/features/profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import '../helpers/seed.dart';

final List<Event> _events = loadSeed().events;

void main() {
  group('forgot password', () {
    testWidgets('unknown email, wrong code, then a new password', (
      tester,
    ) async {
      await setPhoneSize(tester);
      await tester.pumpWidget(
        TestApp(
          auth: const AuthState.guest(),
        ).build(initialLocation: '/auth/forgot'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('forgot-email')),
        'nobody@example.com',
      );
      await tester.tap(find.byKey(const ValueKey('forgot-submit')));
      await tester.pumpAndSettle();
      expect(
        find.text('We could not find an account with that email.'),
        findsOneWidget,
      );

      // The demo account exists once it has been used.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ForgotPasswordScreen)),
      );
      await tester.runAsync(
        () => container.read(authRepositoryProvider).logInDemo(),
      );
      await tester.enterText(
        find.byKey(const ValueKey('forgot-email')),
        kDemoEmail,
      );
      await tester.tap(find.byKey(const ValueKey('forgot-submit')));
      await tester.pumpAndSettle();
      expect(find.textContaining(kDemoEmail), findsWidgets);
      expect(find.byKey(const ValueKey('forgot-password')), findsOneWidget);

      // Too short a code is caught before the repository.
      await tester.enterText(find.byKey(const ValueKey('otp-input')), '12');
      await tester.enterText(
        find.byKey(const ValueKey('forgot-password')),
        'Brand-new#Pass42',
      );
      await tester.tap(find.byKey(const ValueKey('forgot-submit')));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('otp-input')),
        '000000',
      );
      await tester.tap(find.byKey(const ValueKey('forgot-submit')));
      await tester.pumpAndSettle();
      expect(
        find.text('That code is not valid. Request a new one.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('otp-input')),
        kDemoOtpCode,
      );
      await tester.tap(find.byKey(const ValueKey('forgot-submit')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.text('Password updated. Log in with your new password.'),
        findsOneWidget,
      );

      final r = await tester.runAsync(
        () => container
            .read(authRepositoryProvider)
            .logIn(email: kDemoEmail, password: 'Brand-new#Pass42'),
      );
      expect(r!.valueOrNull?.email, kDemoEmail);
    });
  });

  group('share text', () {
    test('paid and free events link to the deep link', () {
      final paid = _events.firstWhere((e) => !e.isFree);
      final free = _events.firstWhere((e) => e.isFree);
      expect(
        eventDeepLink(paid).toString(),
        'https://eventra.app/event/${paid.id}',
      );
      final p = shareText(paid);
      expect(p, contains(paid.title));
      expect(p, contains(eventDeepLink(paid).toString()));
      expect(shareText(free), contains(free.title));
      expect(shareText(free), isNot(equals(p)));
    });
  });

  group('user profile', () {
    test('initials, colors, copyWith and equality', () {
      const a = UserProfile(name: 'Daniel Brooks', city: 'Paris');
      expect(a.initials, 'DB');
      expect(initialsOf('  '), '?');
      expect(initialsOf('cher'), 'C');
      expect(a.color, kAvatarColors.first);
      final b = a.copyWith(bio: 'Live music', avatarColor: 7);
      expect(b.color, kAvatarColors[7 % kAvatarColors.length]);
      expect(b.city, 'Paris');
      expect(b == a, isFalse);
      expect(a.copyWith(), a);
      expect(a.copyWith().hashCode, a.hashCode);
    });

    test('validators', () {
      expect(ProfileValidators.name('A'), isNotNull);
      expect(ProfileValidators.name('A' * 51), isNotNull);
      expect(ProfileValidators.name('Dana Reyes'), isNull);
      expect(ProfileValidators.bio('x' * 161), isNotNull);
      expect(ProfileValidators.bio('Short bio'), isNull);
      expect(ProfileValidators.city('x' * 61), isNotNull);
      expect(ProfileValidators.city('Lyon'), isNull);
    });
  });

  test('logWarning does not throw', () {
    expect(() => logWarning('Brightness unavailable', StateError('x')), returnsNormally);
  });
}
