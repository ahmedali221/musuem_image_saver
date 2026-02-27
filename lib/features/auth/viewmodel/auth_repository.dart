import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:musuem_image_saver/core/network/api_endpoints.dart';
import 'package:musuem_image_saver/core/network/auth_interceptor.dart';
import 'package:musuem_image_saver/features/auth/model/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository({required Dio dio, required FlutterSecureStorage storage})
    : _dio = dio,
      _storage = storage;

  // ── Public Auth ──────────────────────────────────────────────────────────

  /// POST /api/login — returns the Bearer token on success.
  Future<String> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
        if (deviceName != null) 'device_name': deviceName,
      },
    );
    final token = response.data['token'] as String;
    await AuthInterceptor.saveToken(_storage, token);
    return token;
  }

  /// POST /api/register — creates account and returns the Bearer token.
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? deviceName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (deviceName != null) 'device_name': deviceName,
      },
    );
    final token = response.data['token'] as String;
    await AuthInterceptor.saveToken(_storage, token);
    return token;
  }

  // ── Protected Auth ───────────────────────────────────────────────────────

  /// POST /api/logout — revokes the current token.
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
    await AuthInterceptor.deleteToken(_storage);
  }

  /// GET /api/user — returns the authenticated user profile.
  Future<UserModel> getUser() async {
    final response = await _dio.get(ApiEndpoints.user);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Token Utilities ──────────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final token = await AuthInterceptor.readToken(_storage);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() => AuthInterceptor.readToken(_storage);
}
