import 'package:meta/meta.dart';

/// A signed-in Eventra account (never carries the password hash).
@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.verified,
    required this.createdAt,
    this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool verified;
  final DateTime createdAt;

  AppUser copyWith({String? name}) => AppUser(
    id: id,
    name: name ?? this.name,
    email: email,
    phone: phone,
    verified: verified,
    createdAt: createdAt,
  );

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.phone == phone &&
      other.verified == verified;

  @override
  int get hashCode => Object.hash(id, name, email, phone, verified);
}

/// Opaque session stored in secure storage.
@immutable
class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    token: json['token'] as String,
    userId: json['userId'] as String,
    issuedAt: DateTime.parse(json['issuedAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );

  final String token;
  final String userId;
  final DateTime issuedAt;
  final DateTime expiresAt;

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  Map<String, dynamic> toJson() => {
    'token': token,
    'userId': userId,
    'issuedAt': issuedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };
}

enum AuthStatus { unknown, signedOut, guest, signedIn }

/// What the app knows about who is using it.
@immutable
class AuthState {
  const AuthState._(this.status, [this.user]);
  const AuthState.unknown() : this._(AuthStatus.unknown);
  const AuthState.signedOut() : this._(AuthStatus.signedOut);
  const AuthState.guest() : this._(AuthStatus.guest);
  const AuthState.signedIn(AppUser user) : this._(AuthStatus.signedIn, user);

  final AuthStatus status;
  final AppUser? user;

  bool get isRestored => status != AuthStatus.unknown;
  bool get isSignedIn => status == AuthStatus.signedIn;
  bool get isGuest => status == AuthStatus.guest;
  bool get canBrowse => isSignedIn || isGuest;

  /// Key that scopes per-user settings and data.
  String get scope => user?.id ?? 'guest';

  @override
  bool operator ==(Object other) =>
      other is AuthState && other.status == status && other.user == user;

  @override
  int get hashCode => Object.hash(status, user);
}

/// Mock OTP code accepted by the local demo backend (shown in debug builds).
const kDemoOtpCode = '123456';

/// Demo account offered on the login screen.
const kDemoEmail = 'demo@eventra.app';
const kDemoPassword = 'Eventra#2026';
const kDemoName = 'Daniel Brooks';

/// Login attempts allowed before a lockout, and the lockout length.
const kMaxFailedAttempts = 5;
const kLockoutDuration = Duration(seconds: 30);

/// Sessions last 30 days.
const kSessionTtl = Duration(days: 30);

String normalizeEmail(String email) => email.trim().toLowerCase();

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// Inline validators shared by the auth forms (null = valid).
abstract final class AuthValidators {
  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your email';
    if (!_emailPattern.hasMatch(s)) return 'Enter a valid email address';
    return null;
  }

  static String? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your name';
    if (s.length < 2) return 'Name is too short';
    return null;
  }

  static String? phone(String? v) {
    final s = (v ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
    if (s.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(s)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? loginPassword(String? v) =>
      (v ?? '').isEmpty ? 'Enter your password' : null;

  static String? newPassword(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'Use at least 8 characters';
    if (passwordStrength(s) < PasswordStrength.fair) {
      return 'Add numbers, symbols or upper-case letters';
    }
    return null;
  }
}

enum PasswordStrength {
  empty('', 0),
  weak('Weak', 1),
  fair('Fair', 2),
  good('Good', 3),
  strong('Strong', 4);

  const PasswordStrength(this.label, this.level);
  final String label;
  final int level;

  bool operator <(PasswordStrength other) => level < other.level;
}

/// Heuristic strength: length plus character variety, with penalties for
/// very common passwords and single-character repeats.
PasswordStrength passwordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.empty;
  const common = {
    'password',
    'password1',
    '12345678',
    '123456789',
    'qwerty123',
    'iloveyou',
    'eventra123',
  };
  if (common.contains(password.toLowerCase()) ||
      RegExp(r'^(.)\1+$').hasMatch(password)) {
    return PasswordStrength.weak;
  }
  var score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  final variety = [
    RegExp('[a-z]'),
    RegExp('[A-Z]'),
    RegExp('[0-9]'),
    RegExp('[^A-Za-z0-9]'),
  ].where((r) => r.hasMatch(password)).length;
  score += variety - 1;
  if (password.length < 8) score = score.clamp(0, 1);
  return switch (score) {
    <= 1 => PasswordStrength.weak,
    2 => PasswordStrength.fair,
    3 => PasswordStrength.good,
    _ => PasswordStrength.strong,
  };
}
