import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'failure.dart';

/// Turns any thrown object into a [Failure].
///
/// One mapper for the whole app, so a new transport error is handled in a
/// single place instead of in every repository's `catch`. Repositories
/// reach this through `guard()` in `result_guard.dart` rather than calling
/// it directly.
///
/// [unauthorizedMessage] lets a call site override the 401/403 wording —
/// "Invalid email or password" makes sense on a login screen, "Your
/// session has expired" does not.
Failure mapError(Object error, {String? unauthorizedMessage}) {
  return switch (error) {
    // Already mapped (e.g. a use case threw a domain failure) — keep it.
    final Failure failure => failure,
    final DioException e => mapDioException(e, unauthorizedMessage: unauthorizedMessage),
    SocketException() => NetworkFailure(cause: error),
    TimeoutException() => TimeoutFailure(cause: error),
    // Bad JSON shape from an otherwise successful response.
    FormatException() => ServerFailure(
        message: 'Received an unexpected response from the server.',
        cause: error,
      ),
    _ => UnknownFailure(cause: error),
  };
}

/// Maps Dio's transport errors onto the [Failure] hierarchy.
Failure mapDioException(DioException e, {String? unauthorizedMessage}) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return TimeoutFailure(cause: e);

    case DioExceptionType.connectionError:
      return NetworkFailure(cause: e);

    case DioExceptionType.cancel:
      return CancelledFailure(cause: e);

    case DioExceptionType.badCertificate:
      return NetworkFailure(
        message: 'Could not establish a secure connection.',
        cause: e,
      );

    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      // `unknown` also covers a SocketException thrown inside Dio.
      if (e.type == DioExceptionType.unknown && e.error is SocketException) {
        return NetworkFailure(cause: e);
      }
      return _mapStatusCode(e, unauthorizedMessage);
  }
}

Failure _mapStatusCode(DioException e, String? unauthorizedMessage) {
  final statusCode = e.response?.statusCode;

  if (statusCode == 401 || statusCode == 403) {
    return UnauthorizedFailure(
      message: unauthorizedMessage ??
          'Your session has expired. Please sign in again.',
      statusCode: statusCode,
      cause: e,
    );
  }

  if (statusCode == null) {
    return UnknownFailure(cause: e);
  }

  return ServerFailure(
    message: _serverMessage(e) ?? _defaultMessageFor(statusCode),
    statusCode: statusCode,
    cause: e,
  );
}

/// Pulls a human-readable message out of the response body when the API
/// provides one. Anything that isn't a plain string is ignored — a raw
/// payload dumped into a snackbar is worse than a generic message.
String? _serverMessage(DioException e) {
  final data = e.response?.data;
  if (data is! Map) return null;

  final candidate = data['error'] ?? data['message'];
  if (candidate is! String) return null;

  final trimmed = candidate.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _defaultMessageFor(int statusCode) => switch (statusCode) {
      400 => 'That request could not be processed. Please check your input.',
      404 => 'We could not find what you were looking for.',
      409 => 'That conflicts with existing data.',
      422 => 'Some of the information provided is not valid.',
      429 => 'Too many requests. Please wait a moment and try again.',
      >= 500 => 'Something went wrong on our end. Please try again.',
      _ => 'Something went wrong. Please try again.',
    };

/// The string to show a user for any error object.
///
/// UI code should call this instead of `error.toString()`, which leaks
/// type names and exception internals into the interface.
String errorMessageFor(Object? error) {
  if (error is Failure) return error.message;
  if (error == null) return 'Something went wrong. Please try again.';
  return mapError(error).message;
}
