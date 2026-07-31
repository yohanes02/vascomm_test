import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Pure domain entity representing an authenticated user.
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String ktpNumber,
  }) = _User;

  const User._();

  String get fullName => '$firstName $lastName'.trim();
}
