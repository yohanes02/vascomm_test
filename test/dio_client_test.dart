import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vascomm_test/core/config/env.dart';
import 'package:vascomm_test/core/network/dio_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => Env.load());

  test('ApiKeyInterceptor puts the key on every request', () {
    final options = RequestOptions(path: '/login');

    const ApiKeyInterceptor().onRequest(options, RequestInterceptorHandler());

    expect(options.headers['x-api-key'], Env.reqresApiKey);
  });

  test('dioProvider uses the configured base URL', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(dioProvider).options.baseUrl, Env.apiBaseUrl);
  });

  test('request-mutating interceptors run before the logger', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final interceptors = container.read(dioProvider).interceptors;
    final apiKeyIndex = interceptors.indexWhere((i) => i is ApiKeyInterceptor);
    final logIndex = interceptors.indexWhere((i) => i is LogInterceptor);

    expect(apiKeyIndex, isNonNegative);
    // Logging is debug-only. Tests run in debug, so it should be there and
    // sit after anything that decorates the outgoing request.
    expect(logIndex, kDebugMode ? isNonNegative : -1);
    if (kDebugMode) expect(apiKeyIndex, lessThan(logIndex));
  });
}
