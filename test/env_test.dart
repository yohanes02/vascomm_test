import 'package:flutter_test/flutter_test.dart';
import 'package:vascomm_test/core/config/env.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('env/.env is bundled and readable', () async {
    await Env.load();

    expect(Env.apiBaseUrl, isNotEmpty);
    expect(Env.apiBaseUrl, startsWith('http'));
    expect(Env.reqresApiKey, isNotEmpty);
    expect(Env.reqresApiKey, isNot('YOUR_REQRES_API_KEY'));
  });
}
