import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';

/// Attaches the static API key every reqres.in call needs — authenticated
/// or not.
///
/// A named [Interceptor] rather than an inline `InterceptorsWrapper`
/// closure so each concern is its own testable unit and the provider body
/// stays a short, readable list. Once there are several of these they can
/// move to `core/network/interceptors/` without touching call sites.
class ApiKeyInterceptor extends Interceptor {
  const ApiKeyInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['x-api-key'] = Env.reqresApiKey;
    handler.next(options);
  }
}

/// Centralized [Dio] instance — transport concerns only.
///
/// Deliberately *not* responsible for turning responses into domain types
/// or [DioException]s into typed failures: that mapping belongs to the
/// repository/client layer above (see `AuthRepositoryImpl._mapDioError`),
/// so a future `ApiClient` wrapper or a typed `NetworkException` layer can
/// be introduced without rewriting this provider.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Order matters. Request callbacks fire in the order interceptors are
  // added, so anything that mutates the outgoing request has to sit before
  // the logger — otherwise the log shows headers that were never sent.
  dio.interceptors.addAll([
    const ApiKeyInterceptor(),

    // Auth goes here, right after the static headers: an interceptor that
    // reads the stored token (via `ref.read(tokenStorageProvider)`) and
    // sets `Authorization: Bearer <token>` when one exists.

    // A 401/403 interceptor belongs here too — it needs `onError` to
    // refresh the token and retry, with a single-flight guard so parallel
    // 401s trigger one refresh, and a forced logout when that refresh
    // fails. Not built yet; this is where it slots in.

    // A connectivity guard (e.g. `ref.read(networkConnectionProvider)`)
    // could short-circuit requests before they're sent, or live in an
    // `ApiClient` wrapper above this provider.

    // Logging last, so it observes the fully-decorated request.
    //
    // Changed from always-on: LogInterceptor dumps full request and
    // response bodies, which in a release build would write tokens and
    // personal data into device logs (and cost time serialising them on
    // every call). Debug builds only.
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
});
