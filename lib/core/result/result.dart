/// Failure types surfaced to the UI. Never exposes raw exceptions.
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'We could not reach Eventra. Check your connection.',
  ]);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'This event is no longer available.']);
}

final class StorageFailure extends AppFailure {
  const StorageFailure([super.message = 'Local storage is unavailable.']);
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
  const AuthFailure(this.code, super.message, {this.retryAfter});
  final AuthErrorCode code;
  final Duration? retryAfter;
}

/// Ticketing problems (stock, holds, payment, promo, refunds). The enum
/// lives with the ticketing domain.
final class TicketingFailure extends AppFailure {
  const TicketingFailure(this.code, super.message);
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
  const ReviewFailure(this.code, super.message);
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
  const UnknownFailure([super.message = 'Something went wrong.']);
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
