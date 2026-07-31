import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result_guard.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/storage/user_cache_storage.dart';
import '../../domain/entities/auth_params.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Concrete implementation of [AuthRepository], backed by reqres.in.
///
/// reqres.in's login/register only mint a token — no user object comes
/// back, and there's no endpoint to persist profile edits for this auth
/// flow. So this class treats the token as the only thing the server
/// owns, and keeps the richer profile (name, phone, KTP) in
/// [UserCacheStorage] on-device.
///
/// Every method runs inside `guard()`, which converts whatever the data
/// sources throw into a [Failure]. That keeps the exception → failure
/// mapping in one shared place instead of a `catch` ladder per method.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final UserCacheStorage _userCacheStorage;

  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenStorage,
    this._userCacheStorage,
  );

  @override
  Future<Either<Failure, User>> login(LoginParams params) {
    return guard(
      () async {
        final response = await _remoteDataSource.login(
          email: params.email,
          password: params.password,
        );
        await _tokenStorage.saveTokens(accessToken: response.token);

        // No profile comes back from reqres.in — reuse whatever's cached
        // for this email, or fall back to a bare-bones profile derived
        // from the email so the UI has something to render. The user can
        // fill in the rest later via "Simpan Profile".
        final cached = await _userCacheStorage.read();
        final user = (cached != null && cached.email == params.email)
            ? cached
            : UserModel(
                id: params.email,
                firstName: params.email.split('@').first,
                lastName: '',
                email: params.email,
                phone: '',
                ktpNumber: '',
              );
        await _userCacheStorage.save(user);
        return user.toEntity();
      },
      // A 401 here means the credentials were rejected, not that a session
      // expired — the default wording would be misleading on a login form.
      unauthorizedMessage: 'Invalid email or password',
    );
  }

  @override
  Future<Either<Failure, User>> register(RegisterParams params) {
    return guard(() async {
      final response = await _remoteDataSource.register(
        email: params.email,
        password: params.password,
      );
      await _tokenStorage.saveTokens(accessToken: response.token);

      final user = UserModel(
        id: response.id?.toString() ?? params.email,
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        phone: params.phone,
        ktpNumber: params.ktpNumber,
      );
      await _userCacheStorage.save(user);
      return user.toEntity();
    });
  }

  @override
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params) {
    return guard(
      () async {
        final existing = await _userCacheStorage.read();
        final user = UserModel(
          id: existing?.id ?? params.email,
          firstName: params.firstName,
          lastName: params.lastName,
          email: params.email,
          phone: params.phone,
          ktpNumber: params.ktpNumber,
        );
        await _userCacheStorage.save(user);
        return user.toEntity();
      },
      // Local-only write: anything thrown here is a storage problem.
      onError: (error, _) => CacheFailure(cause: error),
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return guard(
      () async {
        await _tokenStorage.clear();
        await _userCacheStorage.clear();
        return unit;
      },
      onError: (error, _) => CacheFailure(
        message: 'Could not clear your saved session.',
        cause: error,
      ),
    );
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() {
    return guard(() async {
      final token = await _tokenStorage.readAccessToken();
      if (token == null) return null;

      final cached = await _userCacheStorage.read();
      return cached?.toEntity();
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(tokenStorageProvider),
    ref.watch(userCacheStorageProvider),
  );
});
