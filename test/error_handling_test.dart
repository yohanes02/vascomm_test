import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vascomm_test/core/error/error_mapper.dart';
import 'package:vascomm_test/core/error/error_reporter.dart';
import 'package:vascomm_test/core/error/failure.dart';
import 'package:vascomm_test/core/error/result_guard.dart';

DioException _dio(DioExceptionType type, {int? status, Object? data}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  group('mapError', () {
    test('timeouts map to a retryable TimeoutFailure', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final failure = mapError(_dio(type));
        expect(failure, isA<TimeoutFailure>(), reason: '$type');
        expect(failure.isRetryable, isTrue);
      }
    });

    test('connection errors and socket exceptions map to NetworkFailure', () {
      expect(mapError(_dio(DioExceptionType.connectionError)), isA<NetworkFailure>());
      expect(mapError(const SocketException('offline')), isA<NetworkFailure>());
      expect(mapError(_dio(DioExceptionType.connectionError)).isRetryable, isTrue);
    });

    test('401/403 map to UnauthorizedFailure with an overridable message', () {
      final generic = mapError(_dio(DioExceptionType.badResponse, status: 401));
      expect(generic, isA<UnauthorizedFailure>());
      expect(generic.isRetryable, isFalse);

      final onLogin = mapError(
        _dio(DioExceptionType.badResponse, status: 401),
        unauthorizedMessage: 'Invalid email or password',
      );
      expect(onLogin.message, 'Invalid email or password');
      expect(mapError(_dio(DioExceptionType.badResponse, status: 403)),
          isA<UnauthorizedFailure>());
    });

    test('server messages are used when present, ignored when not a string', () {
      final withMessage = mapError(
        _dio(DioExceptionType.badResponse, status: 400, data: {'error': 'Missing password'}),
      );
      expect(withMessage.message, 'Missing password');

      final withJunk = mapError(
        _dio(DioExceptionType.badResponse, status: 400, data: {'error': {'nested': 1}}),
      );
      expect(withJunk.message, isNot(contains('nested')));
    });

    test('5xx is retryable, 4xx is not', () {
      expect(mapError(_dio(DioExceptionType.badResponse, status: 503)).isRetryable, isTrue);
      expect(mapError(_dio(DioExceptionType.badResponse, status: 404)).isRetryable, isFalse);
    });

    test('cancellation, timeouts and bad payloads have their own types', () {
      expect(mapError(_dio(DioExceptionType.cancel)), isA<CancelledFailure>());
      expect(mapError(TimeoutException('slow')), isA<TimeoutFailure>());
      expect(mapError(const FormatException('bad json')), isA<ServerFailure>());
    });

    test('an existing Failure passes through untouched', () {
      const failure = ValidationFailure(message: 'Name is required');
      expect(identical(mapError(failure), failure), isTrue);
    });

    test('anything else becomes UnknownFailure', () {
      expect(mapError(Exception('???')), isA<UnknownFailure>());
    });
  });

  group('errorMessageFor', () {
    test('never leaks exception internals to the UI', () {
      final message = errorMessageFor(Exception('DioException [bad state]: token=abc'));
      expect(message, isNot(contains('abc')));
      expect(message, isNot(contains('Exception')));
    });

    test('uses the failure message verbatim', () {
      expect(errorMessageFor(const ValidationFailure(message: 'Name is required')),
          'Name is required');
    });

    test('handles null', () => expect(errorMessageFor(null), isNotEmpty));
  });

  group('guard', () {
    test('wraps a value in right', () async {
      final result = await guard(() async => 42);
      expect(result.getRight().toNullable(), 42);
    });

    test('converts a throw into a mapped Failure', () async {
      final result = await guard<int>(() async => throw _dio(DioExceptionType.cancel));
      expect(result.getLeft().toNullable(), isA<CancelledFailure>());
    });

    test('onError takes precedence', () async {
      final result = await guard<int>(
        () async => throw Exception('disk full'),
        onError: (error, _) => CacheFailure(cause: error),
      );
      expect(result.getLeft().toNullable(), isA<CacheFailure>());
    });

    test('reports unexpected errors, stays quiet for expected ones', () async {
      final reporter = RecordingErrorReporter();
      final previous = ErrorReporter.instance;
      ErrorReporter.instance = reporter;
      addTearDown(() => ErrorReporter.instance = previous);

      await guard<int>(() async => throw _dio(DioExceptionType.connectionError));
      expect(reporter.reports, isEmpty, reason: 'being offline is not a bug');

      await guard<int>(() async => throw Exception('unexpected'));
      expect(reporter.reports, hasLength(1));
    });
  });
}
