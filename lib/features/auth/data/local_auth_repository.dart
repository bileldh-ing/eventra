import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:eventra/core/crypto/pbkdf2.dart';
import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/storage/secure_store.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/domain/auth_repository.dart';
import 'package:eventra/features/auth/domain/password_hasher.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/l10n/l10n.dart';

/// Zero-setup authentication: accounts in the local drift database (salted
/// PBKDF2 hashes only), the session token in secure storage, a mock one-time
/// code and a 5-strike lockout.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({
    required this.db,
    required this.secureStore,
    this.hasher = const PasswordHasher(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final SecureStore secureStore;
  final PasswordHasher hasher;
  final DateTime Function() _clock;

  static const sessionKey = 'eventra.session';
  static const otpTtl = Duration(minutes: 10);

  final _failures = <String, int>{};
  final _lockedUntil = <String, DateTime>{};
  final _otpIssuedAt = <String, DateTime>{};
  final _resetIssuedAt = <String, DateTime>{};

  // ------------------------------------------------------------- sessions

  @override
  Future<AppUser?> restoreSession() async {
    final raw = await secureStore.read(sessionKey);
    if (raw == null) return null;
    AuthSession session;
    try {
      session = AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // Corrupted storage: start clean instead of crashing.
      await secureStore.delete(sessionKey);
      return null;
    }
    if (session.isExpired(_clock())) {
      await secureStore.delete(sessionKey);
      return null;
    }
    final row = await _userWhere('id', session.userId);
    if (row == null) {
      await secureStore.delete(sessionKey);
      return null;
    }
    return _toUser(row);
  }

  /// The stored session (exposed for tests and token-based adapters).
  Future<AuthSession?> currentSession() async {
    final raw = await secureStore.read(sessionKey);
    return raw == null
        ? null
        : AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _startSession(String userId) async {
    final now = _clock();
    final session = AuthSession(
      token: base64UrlNoPad(secureRandomBytes(32)),
      userId: userId,
      issuedAt: now,
      expiresAt: now.add(kSessionTtl),
    );
    await secureStore.write(sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> logOut() => secureStore.delete(sessionKey);

  // -------------------------------------------------------------- sign up

  @override
  Future<Result<AppUser>> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final normalized = normalizeEmail(email);
    if (AuthValidators.newPassword(password) != null) {
      return Result.failure(
        AuthFailure(
          AuthErrorCode.weakPassword,
          AppLocale.l10n.authWeakPassword,
        ),
      );
    }
    if (await _userWhere('email', normalized) != null) {
      return Result.failure(
        AuthFailure(
          AuthErrorCode.emailTaken,
          AppLocale.l10n.authEmailTaken,
        ),
      );
    }
    final user = await _insertUser(
      name: name.trim(),
      email: normalized,
      phone: phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      password: password,
      verified: false,
    );
    _otpIssuedAt[normalized] = _clock();
    return Result.success(user);
  }

  @override
  Future<Result<AppUser>> verifyOtp({
    required String email,
    required String code,
  }) async {
    final normalized = normalizeEmail(email);
    final row = await _userWhere('email', normalized);
    if (row == null) return Result.failure(_userNotFound);
    final issued = _otpIssuedAt[normalized];
    final expired = issued != null && _clock().difference(issued) > otpTtl;
    if (code != kDemoOtpCode || expired) {
      return Result.failure(
        AuthFailure(
          AuthErrorCode.invalidCode,
          expired
              ? AppLocale.l10n.authCodeExpired
              : AppLocale.l10n.authCodeWrong,
        ),
      );
    }
    await db.customUpdate(
      'UPDATE users SET verified = 1 WHERE id = ?',
      variables: [Variable.withString(row.read<String>('id'))],
    );
    _otpIssuedAt.remove(normalized);
    await _startSession(row.read<String>('id'));
    return Result.success(_toUser(row, verified: true));
  }

  @override
  Future<Result<void>> resendOtp(String email) async {
    final normalized = normalizeEmail(email);
    if (await _userWhere('email', normalized) == null) {
      return Result.failure(_userNotFound);
    }
    _otpIssuedAt[normalized] = _clock();
    return const Result.success(null);
  }

  // --------------------------------------------------------------- log in

  @override
  Duration? lockoutRemaining(String email) {
    final until = _lockedUntil[normalizeEmail(email)];
    if (until == null) return null;
    final left = until.difference(_clock());
    if (left <= Duration.zero) {
      _lockedUntil.remove(normalizeEmail(email));
      _failures.remove(normalizeEmail(email));
      return null;
    }
    return left;
  }

  @override
  Future<Result<AppUser>> logIn({
    required String email,
    required String password,
  }) async {
    final normalized = normalizeEmail(email);
    final locked = lockoutRemaining(normalized);
    if (locked != null) return Result.failure(_lockedOut(locked));

    final row = await _userWhere('email', normalized);
    final ok =
        row != null &&
        await hasher.verify(
          password,
          PasswordHash(
            hash: row.read<String>('password_hash'),
            salt: row.read<String>('salt'),
            iterations: row.read<int>('iterations'),
          ),
        );
    if (!ok) {
      final count = (_failures[normalized] ?? 0) + 1;
      _failures[normalized] = count;
      if (count >= kMaxFailedAttempts) {
        _lockedUntil[normalized] = _clock().add(kLockoutDuration);
        return Result.failure(_lockedOut(kLockoutDuration));
      }
      final left = kMaxFailedAttempts - count;
      return Result.failure(
        AuthFailure(
          AuthErrorCode.invalidCredentials,
          AppLocale.l10n.authBadCredentials(left),
        ),
      );
    }
    _failures.remove(normalized);
    if (row.read<int>('verified') == 0) {
      _otpIssuedAt[normalized] = _clock();
      return Result.failure(
        AuthFailure(
          AuthErrorCode.unverified,
          AppLocale.l10n.authUnverified,
        ),
      );
    }
    await _startSession(row.read<String>('id'));
    return Result.success(_toUser(row));
  }

  @override
  Future<Result<AppUser>> logInDemo() async {
    var row = await _userWhere('email', kDemoEmail);
    if (row == null) {
      await _insertUser(
        name: kDemoName,
        email: kDemoEmail,
        password: kDemoPassword,
        verified: true,
      );
      row = await _userWhere('email', kDemoEmail);
    }
    await _startSession(row!.read<String>('id'));
    return Result.success(_toUser(row));
  }

  // ------------------------------------------------------- password reset

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    final normalized = normalizeEmail(email);
    if (await _userWhere('email', normalized) == null) {
      return Result.failure(_userNotFound);
    }
    _resetIssuedAt[normalized] = _clock();
    return const Result.success(null);
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final normalized = normalizeEmail(email);
    final issued = _resetIssuedAt[normalized];
    if (issued == null ||
        code != kDemoOtpCode ||
        _clock().difference(issued) > otpTtl) {
      return Result.failure(
        AuthFailure(
          AuthErrorCode.invalidCode,
          AppLocale.l10n.authCodeInvalid,
        ),
      );
    }
    if (AuthValidators.newPassword(newPassword) != null) {
      return Result.failure(
        AuthFailure(
          AuthErrorCode.weakPassword,
          AppLocale.l10n.authWeakPassword,
        ),
      );
    }
    final h = await hasher.hash(newPassword);
    await db.customUpdate(
      'UPDATE users SET password_hash = ?, salt = ?, iterations = ? '
      'WHERE email = ?',
      variables: [
        Variable.withString(h.hash),
        Variable.withString(h.salt),
        Variable.withInt(h.iterations),
        Variable.withString(normalized),
      ],
    );
    _resetIssuedAt.remove(normalized);
    _failures.remove(normalized);
    _lockedUntil.remove(normalized);
    return const Result.success(null);
  }

  // -------------------------------------------------------------- storage

  static AuthFailure get _userNotFound => AuthFailure(
    AuthErrorCode.userNotFound,
    AppLocale.l10n.authUserNotFound,
  );

  AuthFailure _lockedOut(Duration left) => AuthFailure(
    AuthErrorCode.lockedOut,
    AppLocale.l10n.authLockedOut(left.inSeconds.clamp(1, 999).toString()),
    retryAfter: left,
  );

  Future<QueryRow?> _userWhere(String column, String value) => db
      .customSelect(
        'SELECT * FROM users WHERE $column = ?',
        variables: [Variable.withString(value)],
      )
      .getSingleOrNull();

  Future<AppUser> _insertUser({
    required String name,
    required String email,
    required String password,
    required bool verified,
    String? phone,
  }) async {
    final h = await hasher.hash(password);
    final id = 'u_${base64UrlNoPad(secureRandomBytes(9))}';
    final now = _clock();
    await db.customInsert(
      'INSERT INTO users (id, email, name, phone, password_hash, salt, '
      'iterations, verified, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(id),
        Variable.withString(email),
        Variable.withString(name),
        Variable(phone),
        Variable.withString(h.hash),
        Variable.withString(h.salt),
        Variable.withInt(h.iterations),
        Variable.withInt(verified ? 1 : 0),
        Variable.withInt(now.millisecondsSinceEpoch),
      ],
    );
    return AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      verified: verified,
      createdAt: now,
    );
  }

  /// Raw row access for tests (proves no plain-text password is stored).
  Future<Map<String, Object?>?> rawUser(String email) async =>
      (await _userWhere('email', normalizeEmail(email)))?.data;

  AppUser _toUser(QueryRow r, {bool? verified}) => AppUser(
    id: r.read<String>('id'),
    name: r.read<String>('name'),
    email: r.read<String>('email'),
    phone: r.readNullable<String>('phone'),
    verified: verified ?? r.read<int>('verified') == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.read<int>('created_at')),
  );
}
