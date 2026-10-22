import 'package:eventra/app/auth_guard.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

final _user = AppUser(
  id: 'u1',
  name: 'Ada Lovelace',
  email: 'ada@example.com',
  verified: true,
  createdAt: DateTime(2026),
);

String? go(String location, AuthState auth, {bool seen = true}) =>
    authRedirect(auth: auth, onboardingSeen: seen, uri: Uri.parse(location));

void main() {
  const guest = AuthState.guest();
  const out = AuthState.signedOut();
  final inside = AuthState.signedIn(_user);

  test('everything waits on the splash until the session is restored', () {
    expect(go('/splash', const AuthState.unknown()), isNull);
    final r = Uri.parse(go('/home/event/e1', const AuthState.unknown())!);
    expect(r.path, '/splash');
    expect(r.queryParameters['from'], '/home/event/e1');
  });

  test('first launch shows onboarding before anything else', () {
    expect(go('/home', out, seen: false), '/onboarding');
    expect(go('/onboarding', out, seen: false), isNull);
    expect(go('/auth/login', out, seen: false), isNull);
  });

  test('signed-out users are sent to log in and come back to from', () {
    final r = Uri.parse(go('/explore', out)!);
    expect(r.path, '/auth/login');
    expect(r.queryParameters['from'], '/explore');
    expect(go('/auth/signup', out), isNull);
  });

  test('guests browse Home, Explore and Details but not tickets', () {
    expect(go('/home', guest), isNull);
    expect(go('/explore', guest), isNull);
    expect(go('/home/event/e1', guest), isNull);
    expect(go('/favorites', guest), isNull);
    for (final p in ['/home/event/e1/tickets', '/profile/tickets']) {
      final r = Uri.parse(go(p, guest)!);
      expect(r.path, '/auth/login');
      expect(r.queryParameters['from'], p);
    }
  });

  test('signed-in users reach tickets and skip the login page', () {
    expect(go('/home/event/e1/tickets', inside), isNull);
    expect(go('/auth/login', inside), '/home');
    expect(
      go('/auth/login?from=%2Fhome%2Fevent%2Fe1%2Ftickets', inside),
      '/home/event/e1/tickets',
    );
    // Never follow an off-site redirect.
    expect(go('/auth/login?from=%2F%2Fevil.com', inside), '/home');
    expect(go('/auth/otp', inside), isNull);
  });

  test('wallet, checkout and success pages need an account (Phase 7)', () {
    for (final p in [
      '/tickets',
      '/tickets/tkt_1',
      '/checkout/hold_1',
      '/booking-success/ord_1',
      '/my-tickets',
    ]) {
      final r = Uri.parse(go(p, guest)!);
      expect(r.path, '/auth/login', reason: p);
      expect(r.queryParameters['from'], p);
      expect(go(p, inside), isNull, reason: p);
    }
    // A tickets-like word elsewhere is not protected.
    expect(go('/home/ticketsearch', guest), isNull);
  });
}
