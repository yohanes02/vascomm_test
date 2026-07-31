import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vascomm_test/core/error/failure.dart';
import 'package:vascomm_test/features/home/presentation/pages/home_page.dart';
import 'package:vascomm_test/core/routing/app_router.dart';
import 'package:vascomm_test/core/theme/app_theme.dart';
import 'package:vascomm_test/features/auth/domain/entities/auth_params.dart';
import 'package:vascomm_test/features/auth/domain/entities/user.dart';
import 'package:vascomm_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:vascomm_test/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vascomm_test/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vascomm_test/features/auth/presentation/pages/login_page.dart';

const _user = User(
  id: '1',
  firstName: 'Angga',
  lastName: 'Praja',
  email: 'angga@example.com',
  phone: '',
  ktpNumber: '',
);

/// In-memory stand-in for the real repository: `logout()` wipes the same
/// state a token + cached profile would occupy on device.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.failOnLogout = false});

  final bool failOnLogout;
  User? storedUser = _user;
  String? storedToken = 'token-123';
  int logoutCalls = 0;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async =>
      right(storedToken == null ? null : storedUser);

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    if (failOnLogout) return left(const CacheFailure());
    storedToken = null;
    storedUser = null;
    return right(unit);
  }

  @override
  Future<Either<Failure, User>> login(LoginParams params) async => right(_user);

  @override
  Future<Either<Failure, User>> register(RegisterParams params) async => right(_user);

  @override
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params) async => right(_user);
}

Future<ProviderContainer> _pumpApp(WidgetTester tester, _FakeAuthRepository repository) async {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: ref.watch(appRouterProvider),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('logout clears the session and returns to Login', (tester) async {
    final repository = _FakeAuthRepository();
    final container = await _pumpApp(tester, repository);

    // A restored session lands on Home.
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);

    await container.read(authControllerProvider.notifier).logout();
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
    expect(repository.storedToken, isNull, reason: 'token must be deleted');
    expect(repository.storedUser, isNull, reason: 'cached profile must be deleted');
    expect(container.read(authControllerProvider).valueOrNull, isNull);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('no session cannot reach Home', (tester) async {
    final repository = _FakeAuthRepository()
      ..storedToken = null
      ..storedUser = null;
    await _pumpApp(tester, repository);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('a failed storage wipe still ends the session', (tester) async {
    final repository = _FakeAuthRepository(failOnLogout: true);
    final container = await _pumpApp(tester, repository);

    expect(find.byType(HomePage), findsOneWidget);

    final failure = await container.read(authControllerProvider.notifier).logout();
    await tester.pumpAndSettle();

    // The failure is reported to the caller rather than swallowed...
    expect(failure, isA<CacheFailure>());
    // ...but the session still ends and the user lands on Login.
    expect(container.read(authControllerProvider).valueOrNull, isNull);
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
