import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_params.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the "create a new account" business action.
class RegisterUser {
  final AuthRepository _repository;

  const RegisterUser(this._repository);

  Future<Either<Failure, User>> call(RegisterParams params) async {
    if (params.firstName.trim().isEmpty || params.lastName.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Name is required'));
    }
    if (!params.email.contains('@')) {
      return left(const ValidationFailure(message: 'Enter a valid email address'));
    }
    if (params.phone.trim().isEmpty) {
      return left(const ValidationFailure(message: 'Phone number is required'));
    }
    if (params.ktpNumber.trim().isEmpty) {
      return left(const ValidationFailure(message: 'KTP number is required'));
    }
    if (params.password.length < 6) {
      return left(
        const ValidationFailure(message: 'Password must be at least 6 characters'),
      );
    }
    return _repository.register(params);
  }
}
