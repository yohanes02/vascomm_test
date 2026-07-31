import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';

/// Talks to reqres.in's `/login` and `/register` endpoints only. Throws
/// [DioException] on failure — translating that into a [Failure] is the
/// repository's job.
///
/// Note: reqres.in has no endpoint to fetch or update a logged-in user's
/// profile for this auth flow, so there's no `getCurrentUser`/
/// `updateProfile` here — [AuthRepositoryImpl] handles those locally.
class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/register',
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});
