import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_params.freezed.dart';

/// Input for the login use case. A dedicated type (rather than raw
/// positional Strings) keeps call sites self-documenting and makes it
/// easy to add fields (e.g. a "remember me" flag) without breaking
/// every call site.
@freezed
class LoginParams with _$LoginParams {
  const factory LoginParams({
    required String email,
    required String password,
  }) = _LoginParams;
}

/// Input for the register use case.
@freezed
class RegisterParams with _$RegisterParams {
  const factory RegisterParams({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String ktpNumber,
    required String password,
  }) = _RegisterParams;
}

/// Input for updating the authenticated user's profile details.
@freezed
class UpdateProfileParams with _$UpdateProfileParams {
  const factory UpdateProfileParams({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String ktpNumber,
  }) = _UpdateProfileParams;
}
