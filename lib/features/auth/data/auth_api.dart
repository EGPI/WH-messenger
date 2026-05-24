import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import 'auth_models.dart';

class AuthApi {
  final Dio _dio;

  const AuthApi(this._dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

}

