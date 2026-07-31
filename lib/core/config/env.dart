import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration, read from `env/.env` at the project root.
///
/// That file is gitignored; `env/.env.example` is the committed template.
/// [load] must run before anything reads these values — `main()` awaits it
/// before `runApp`.
class Env {
  Env._();

  static const fileName = 'env/.env';

  /// Reads the env file into memory. Safe to call more than once.
  static Future<void> load() => dotenv.load(fileName: fileName);

  /// Base URL for the API, e.g. `https://reqres.in/api`.
  static String get apiBaseUrl => _require('API_BASE_URL');

  /// reqres.in requires this header on every request.
  static String get reqresApiKey => _require('REQRES_API_KEY');

  static String _require(String key) {
    if (!dotenv.isInitialized) {
      throw StateError(
        'Env.load() has not run yet — call it before reading Env.$key '
        '(main() awaits it before runApp).',
      );
    }
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing "$key" in $fileName. Copy env/.env.example to env/.env '
        'and fill it in.',
      );
    }
    return value;
  }
}
