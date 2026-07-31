import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_params.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/update_profile.dart';

/// Single source of truth for the current auth session.
///
/// `state.value == null` means "logged out", a non-null [User] means
/// "logged in". `go_router`'s redirect logic (see `core/routing/app_router.dart`)
/// listens to this provider to decide which screens are reachable.
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final result = await GetCurrentUser(repository)();
    return result.match((failure) => throw failure, (user) => user);
  }

  /// Note: deliberately does NOT set `state = AsyncValue.loading()` while
  /// the request is in flight. `authControllerProvider`'s loading state
  /// also drives the app-wide splash screen (see `main.dart`) and the
  /// router's "still resolving session" check — reusing it here would
  /// hide the login form behind a full-screen spinner mid-submit. Each
  /// page tracks its own submitting flag for the button instead.
  Future<void> login({required String email, required String password}) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await LoginUser(repository)(
      LoginParams(email: email, password: password),
    );
    state = result.match(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String ktpNumber,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await RegisterUser(repository)(
      RegisterParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        ktpNumber: ktpNumber,
        password: password,
      ),
    );
    state = result.match(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String ktpNumber,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await UpdateProfile(repository)(
      UpdateProfileParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        ktpNumber: ktpNumber,
      ),
    );
    state = result.match(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  /// Clears the stored token and cached profile, then drops the in-memory
  /// session so the router's redirect sends the user back to Login.
  ///
  /// The session is always dropped, even if wiping storage failed — the
  /// user asked to leave, so they must not be left on an authenticated
  /// screen. The failure is returned (rather than pushed into [state],
  /// which would leave the router unable to tell "logged out" from
  /// "logged in but something went wrong") so the caller can report that
  /// the credentials may still be on the device. Returns null on success.
  Future<Failure?> logout() async {
    final repository = ref.read(authRepositoryProvider);
    final result = await LogoutUser(repository)();
    state = const AsyncValue.data(null);
    return result.match((failure) => failure, (_) => null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);
