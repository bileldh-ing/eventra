import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/storage/secure_store.dart';
import 'package:eventra/features/auth/data/local_auth_repository.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/domain/password_hasher.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

const _pw = 'Sunset#Rooftop7';
const _email = 'ada@example.com';

AuthErrorCode? code(Result<Object?> r) => switch (r) {
  Failure(:final failure) when failure is AuthFailure => failure.code,
  _ => null,
};

Duration? retryAfter(Result<Object?> r) => switch (r) {
  Failure(:final failure) when failure is AuthFailure => failure.retryAfter,
  _ => null,
};

void main() {
  late AppDatabase db;
  late MemorySecureStore secure;
  late DateTime now;
  late LocalAuthRepository repo;

  LocalAuthRepository make() => LocalAuthRepository(
    db: db,
    secureStore: secure,
    hasher: const PasswordHasher(iterations: 2),
    clock: () => now,
  );

  setUp(() {
    db = memoryDb();
    secure = MemorySecureStore();
    now = DateTime(2026, 10, 21, 10);
    repo = make();
  });
  tearDown(() => db.close());

  Future<AppUser> signUpVerified() async {
    await repo.signUp(name: 'Ada Lovelace', email: _email, password: _pw);
    final r = await repo.verifyOtp(email: _email, code: kDemoOtpCode);
    return r.valueOrNull!;
  }

  test('sign up rejects a duplicate email, case-insensitively', () async {
    final first = await repo.signUp(
      name: 'Ada Lovelace',
      email: 'Ada@Example.com ',
      password: _pw,
    );
    expect(first.valueOrNull?.email, _email);
    expect(first.valueOrNull?.verified, isFalse);
    final dup = await repo.signUp(
      name: 'Someone Else',
      email: _email,
      password: _pw,
    );
    expect(code(dup), AuthErrorCode.emailTaken);
  });

  test('weak passwords are refused', () async {
    final r = await repo.signUp(name: 'Ada', email: _email, password: 'pass');
    expect(code(r), AuthErrorCode.weakPassword);
  });

  test(
    'passwords are stored only as salted hashes, never plain text',
    () async {
      await repo.signUp(name: 'Ada', email: _email, password: _pw);
      final row = (await repo.rawUser(_email))!;
      expect(row.values.any((v) => '$v'.contains(_pw)), isFalse);
      expect(row['password_hash'], isNot(isEmpty));
      expect(row['salt'], isNot(isEmpty));
      expect(row['iterations'], 2);
    },
  );

  test('OTP: wrong code fails, 123456 verifies and starts a session', () async {
    await repo.signUp(name: 'Ada', email: _email, password: _pw);
    final login = await repo.logIn(email: _email, password: _pw);
    expect(code(login), AuthErrorCode.unverified);
    final bad = await repo.verifyOtp(email: _email, code: '000000');
    expect(code(bad), AuthErrorCode.invalidCode);
    expect(await secure.read(LocalAuthRepository.sessionKey), isNull);
    final ok = await repo.verifyOtp(email: _email, code: kDemoOtpCode);
    expect(ok.valueOrNull?.verified, isTrue);
    expect(await secure.read(LocalAuthRepository.sessionKey), isNotNull);
  });

  test('OTP codes expire after 10 minutes', () async {
    await repo.signUp(name: 'Ada', email: _email, password: _pw);
    now = now.add(const Duration(minutes: 11));
    final r = await repo.verifyOtp(email: _email, code: kDemoOtpCode);
    expect(code(r), AuthErrorCode.invalidCode);
  });

  test('5 failed attempts lock the account for 30s (fake clock)', () async {
    await signUpVerified();
    await repo.logOut();
    for (var i = 1; i < kMaxFailedAttempts; i++) {
      final r = await repo.logIn(email: _email, password: 'nope');
      expect(code(r), AuthErrorCode.invalidCredentials);
    }
    final fifth = await repo.logIn(email: _email, password: 'nope');
    expect(code(fifth), AuthErrorCode.lockedOut);
    expect(retryAfter(fifth), kLockoutDuration);

    // Even the right password is refused while locked.
    now = now.add(const Duration(seconds: 20));
    expect(
      repo.lockoutRemaining('ADA@example.com'),
      const Duration(seconds: 10),
    );
    final during = await repo.logIn(email: _email, password: _pw);
    expect(code(during), AuthErrorCode.lockedOut);

    now = now.add(const Duration(seconds: 11));
    expect(repo.lockoutRemaining(_email), isNull);
    final after = await repo.logIn(email: _email, password: _pw);
    expect(after.valueOrNull?.email, _email);
  });

  test('a relaunch restores the session; it expires after 30 days', () async {
    final user = await signUpVerified();
    // A new repository over the same stores is an app relaunch.
    expect((await make().restoreSession())?.id, user.id);

    now = now.add(kSessionTtl + const Duration(minutes: 1));
    expect(await make().restoreSession(), isNull);
    expect(await secure.read(LocalAuthRepository.sessionKey), isNull);
  });

  test('log out clears the session; corrupt storage is ignored', () async {
    await signUpVerified();
    await repo.logOut();
    expect(await repo.restoreSession(), isNull);
    await secure.write(LocalAuthRepository.sessionKey, '{not json');
    expect(await repo.restoreSession(), isNull);
  });

  test('demo account is created once and reused', () async {
    final a = await repo.logInDemo();
    final b = await repo.logInDemo();
    expect(a.valueOrNull?.email, kDemoEmail);
    expect(b.valueOrNull?.id, a.valueOrNull?.id);
    await repo.logOut();
    final login = await repo.logIn(email: kDemoEmail, password: kDemoPassword);
    expect(login.isSuccess, isTrue);
  });

  test('password reset with the code replaces the password', () async {
    await signUpVerified();
    expect(
      code(await repo.requestPasswordReset('nobody@example.com')),
      AuthErrorCode.userNotFound,
    );
    expect((await repo.requestPasswordReset(_email)).isSuccess, isTrue);
    final wrong = await repo.resetPassword(
      email: _email,
      code: '111111',
      newPassword: 'Brand#New2026',
    );
    expect(code(wrong), AuthErrorCode.invalidCode);
    final ok = await repo.resetPassword(
      email: _email,
      code: kDemoOtpCode,
      newPassword: 'Brand#New2026',
    );
    expect(ok.isSuccess, isTrue);
    expect(
      code(await repo.logIn(email: _email, password: _pw)),
      AuthErrorCode.invalidCredentials,
    );
    final fresh = await repo.logIn(email: _email, password: 'Brand#New2026');
    expect(fresh.isSuccess, isTrue);
  });

  test('password strength heuristic and validators', () {
    expect(passwordStrength(''), PasswordStrength.empty);
    expect(passwordStrength('abc'), PasswordStrength.weak);
    expect(passwordStrength('password1'), PasswordStrength.weak);
    expect(passwordStrength('sunsets12'), PasswordStrength.fair);
    expect(passwordStrength('Sunsets12'), PasswordStrength.good);
    expect(passwordStrength(_pw), PasswordStrength.strong);
    expect(AuthValidators.email('ada@example'), isNotNull);
    expect(AuthValidators.email(_email), isNull);
    expect(AuthValidators.phone(''), isNull);
    expect(AuthValidators.phone('+1 (845) 555-0100'), isNull);
    expect(AuthValidators.phone('12ab'), isNotNull);
  });
}
