import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';

/// Authentication boundary. The default implementation is fully local (drift
/// + secure storage); a Firebase or REST adapter can replace it unchanged.
abstract interface class AuthRepository {
  /// The stored session's user, or null when there is none or it expired.
  Future<AppUser?> restoreSession();

  /// Creates an unverified account and sends a one-time code.
  Future<Result<AppUser>> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// Confirms the code sent at sign-up and starts a session.
  Future<Result<AppUser>> verifyOtp({
    required String email,
    required String code,
  });

  Future<Result<void>> resendOtp(String email);

  Future<Result<AppUser>> logIn({
    required String email,
    required String password,
  });

  /// Signs in to the bundled demo account (created on first use).
  Future<Result<AppUser>> logInDemo();

  Future<Result<void>> requestPasswordReset(String email);

  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Time left on a lockout for [email], or null when not locked.
  Duration? lockoutRemaining(String email);

  Future<void> logOut();
}
