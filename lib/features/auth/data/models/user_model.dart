import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data Transfer Object for the API's user representation.
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String ktpNumber,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  User toEntity() => User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        ktpNumber: ktpNumber,
      );
}
