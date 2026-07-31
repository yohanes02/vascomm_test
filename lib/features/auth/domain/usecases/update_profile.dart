import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_params.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the "update my profile details" business action.
class UpdateProfile {
  final AuthRepository _repository;

  const UpdateProfile(this._repository);

  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
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
    return _repository.updateProfile(params);
  }
}
