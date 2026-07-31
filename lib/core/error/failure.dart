/// Base class for all domain/data-layer failures.
///
/// Kept deliberately simple (no Freezed) so `core/` has zero dependency
/// on codegen tooling — only the feature layers need Freezed.
///
/// Two rules keep this useful as the app grows:
///
/// 1. [message] is **safe to show a user**. Never put an exception's
///    `toString()`, a stack trace, or a raw server payload in it — those
///    go in [cause], which is for logs and crash reports only.
/// 2. Nothing above the data layer catches raw exceptions. Data sources
///    throw, repositories convert to a [Failure] (see
///    `core/error/result_guard.dart`), and everything above works with
///    `Either<Failure, T>`.
sealed class Failure {
  final String message;

  /// The underlying exception/error, for logging and crash reporting.
  /// Never surfaced to users.
  final Object? cause;

  const Failure(this.message, {this.cause});

  /// Whether retrying the same call could plausibly succeed. Lets the UI
  /// offer "Try again" without switching on failure types.
  bool get isRetryable => false;

  @override
  String toString() => '$runtimeType: $message';
}

/// No usable connection (offline, DNS, connection refused, TLS).
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection. Check your network and try again.',
    super.cause,
  }) : super(message);

  @override
  bool get isRetryable => true;
}

/// The request was sent but connecting/sending/receiving took too long.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'The connection timed out. Please try again.',
    super.cause,
  }) : super(message);

  @override
  bool get isRetryable => true;
}

/// Non-2xx response. [statusCode] is null when the server replied with
/// something unparseable.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    String message = 'Something went wrong on our end. Please try again.',
    this.statusCode,
    super.cause,
  }) : super(message);

  /// 5xx is worth retrying; a 4xx will fail the same way again.
  @override
  bool get isRetryable => statusCode == null || statusCode! >= 500;
}

/// 401/403 — credentials rejected, or the session is no longer valid.
/// Callers can treat this as "force a re-login".
class UnauthorizedFailure extends Failure {
  final int? statusCode;

  const UnauthorizedFailure({
    String message = 'Your session has expired. Please sign in again.',
    this.statusCode,
    super.cause,
  }) : super(message);
}

/// The request was cancelled deliberately (screen disposed, user aborted).
/// Usually not worth showing at all.
class CancelledFailure extends Failure {
  const CancelledFailure({
    String message = 'The request was cancelled.',
    super.cause,
  }) : super(message);
}

/// Reading/writing local persistence failed.
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Could not access local data. Please try again.',
    super.cause,
  }) : super(message);
}

/// Validation / business-rule violation raised in the domain layer.
class ValidationFailure extends Failure {
  /// Optional per-field messages keyed by field name, for forms that want
  /// to highlight inputs instead of showing one banner.
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required String message,
    this.fieldErrors = const {},
    super.cause,
  }) : super(message);
}

/// Catch-all for anything unexpected. Prefer a specific Failure where
/// possible — an [UnknownFailure] in the logs means the mapper is missing
/// a case.
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Something went wrong. Please try again.',
    super.cause,
  }) : super(message);
}
