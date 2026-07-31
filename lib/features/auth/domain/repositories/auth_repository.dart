import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_params.dart';
import '../entities/user.dart';

/// Domain-layer contract for authentication. The data layer supplies the
/// concrete implementation (talking to the API + secure token storage).
abstract interface class AuthRepository {
  /// Logs in with email/password, persists the session token, and
  /// returns the authenticated user.
  Future<Either<Failure, User>> login(LoginParams params);

  /// Registers a new account, persists the session token, and returns
  /// the newly created user.
  Future<Either<Failure, User>> register(RegisterParams params);

  /// Updates the authenticated user's profile details.
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params);

  /// Clears the persisted session.
  Future<Either<Failure, Unit>> logout();

  /// Returns the currently authenticated user, if a valid session
  /// exists, or `null` if the user is logged out.
  Future<Either<Failure, User?>> getCurrentUser();
}
