import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the "log the user out" business action.
class LogoutUser {
  final AuthRepository _repository;

  const LogoutUser(this._repository);

  Future<Either<Failure, Unit>> call() => _repository.logout();
}
