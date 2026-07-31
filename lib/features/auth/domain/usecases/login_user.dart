import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_params.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the "log a user in" business action, including basic
/// input validation that belongs to the domain, not the UI or the API.
class LoginUser {
  final AuthRepository _repository;

  const LoginUser(this._repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    if (!params.email.contains('@')) {
      return left(const ValidationFailure(message: 'Enter a valid email address'));
    }
    if (params.password.length < 6) {
      return left(
        const ValidationFailure(message: 'Password must be at least 6 characters'),
      );
    }
    return _repository.login(params);
  }
}
