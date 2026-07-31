import 'package:fpdart/fpdart.dart';

import 'error_mapper.dart';
import 'error_reporter.dart';
import 'failure.dart';

/// Runs [body] and converts anything it throws into a [Failure].
///
/// This is the single boundary between "code that throws" (data sources,
/// plugins, parsing) and "code that returns `Either`" (repositories and
/// up). Repository methods become one line each, and a new exception type
/// is handled once in `mapError` instead of in every `catch` block.
///
/// ```dart
/// @override
/// Future<Either<Failure, User>> login(LoginParams params) =>
///     guard(() async {
///       final response = await _remote.login(...);
///       return response.toEntity();
///     }, unauthorizedMessage: 'Invalid email or password');
/// ```
///
/// [unauthorizedMessage] overrides the wording for 401/403 (see
/// [mapError]). [onError] takes precedence when a call needs bespoke
/// mapping — return null from it to fall back to the default.
Future<Either<Failure, T>> guard<T>(
  Future<T> Function() body, {
  String? unauthorizedMessage,
  Failure? Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    return right(await body());
  } catch (error, stackTrace) {
    final failure = onError?.call(error, stackTrace) ??
        mapError(error, unauthorizedMessage: unauthorizedMessage);

    // Unexpected failures are worth a crash report; an offline device or a
    // rejected password is not.
    if (failure is UnknownFailure) {
      ErrorReporter.instance.report(error, stackTrace, context: 'guard');
    }

    return left(failure);
  }
}
