import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates "is there a valid session, and if so who is it for" —
/// used on app start to decide whether to show the login screen.
class GetCurrentUser {
  final AuthRepository _repository;

  const GetCurrentUser(this._repository);

  Future<Either<Failure, User?>> call() => _repository.getCurrentUser();
}
