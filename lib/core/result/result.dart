import 'package:eventra/l10n/l10n.dart';

/// Failure types surfaced to the UI. Never exposes raw exceptions.
sealed class AppFailure {
  const AppFailure([this._message]);
  final String? _message;

  /// User-facing text in the active language. A specific message given at
  /// construction wins over the type's default.
  String get message => _message ?? defaultMessage;

  String get defaultMessage;

  @override
  String toString() => message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super._message]);

  @override
  String get defaultMessage => AppLocale.l10n.errNetwork;
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super._message]);

  @override
  String get defaultMessage => AppLocale.l10n.errEventGone;
}

final class StorageFailure extends AppFailure {
  const StorageFailure([super._message]);

  @override
  String get defaultMessage => AppLocale.l10n.errStorage;
}

enum AuthErrorCode {
  emailTaken,
  invalidCredentials,
  lockedOut,
  unverified,
  invalidCode,
  userNotFound,
  weakPassword,
}

/// Sign-in / sign-up problems. [retryAfter] is set while locked out.
final class AuthFailure extends AppFailure {
  const AuthFailure(this.code, super._message, {this.retryAfter});

  @override
  String get defaultMessage => AppLocale.l10n.errUnknown;
  final AuthErrorCode code;
  final Duration? retryAfter;
}

/// Ticketing problems (stock, holds, payment, promo, refunds). The enum
/// lives with the ticketing domain.
final class TicketingFailure extends AppFailure {
  const TicketingFailure(this.code, super._message);

  @override
  String get defaultMessage => AppLocale.l10n.errUnknown;
  final TicketingError code;
}

enum TicketingError {
  soldOut,
  invalidSelection,
  holdExpired,
  holdNotFound,
  paymentDeclined,
  paymentTimeout,
  authenticationFailed,
  promoInvalid,
  refundNotAllowed,
  orderNotFound,
}

/// Review rule violations (eligibility, validation, ownership).
final class ReviewFailure extends AppFailure {
  const ReviewFailure(this.code, super._message);

  @override
  String get defaultMessage => AppLocale.l10n.errUnknown;
  final ReviewError code;
}

enum ReviewError {
  notAllowed,
  invalidRating,
  tooShort,
  tooLong,
  duplicate,
  notFound,
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super._message]);

  @override
  String get defaultMessage => AppLocale.l10n.errUnknown;
}

/// Sealed success/failure result used by every repository.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  R fold<R>(R Function(T value) onSuccess, R Function(AppFailure f) onFail) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        Failure(:final failure) => onFail(failure),
      };

  Result<R> map<R>(R Function(T value) f) => switch (this) {
    Success(:final value) => Result.success(f(value)),
    Failure(:final failure) => Result.failure(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final AppFailure failure;
}

/// Thrown by repositories' providers so AsyncValue carries a typed failure.
class FailureException implements Exception {
  const FailureException(this.failure);
  final AppFailure failure;

  @override
  String toString() => failure.message;
}
