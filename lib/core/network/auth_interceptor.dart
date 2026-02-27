import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor that automatically injects the stored Bearer token into every
/// outgoing request, and clears the token on 401 responses.
class AuthInterceptor extends Interceptor {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token is invalid / expired — clear it so app navigates to login.
      _storage.delete(key: _tokenKey);
    }
    handler.next(err);
  }

  // ── Static helpers used by AuthRepository ─────────────────────────────────

  static Future<void> saveToken(
    FlutterSecureStorage storage,
    String token,
  ) async {
    await storage.write(key: _tokenKey, value: token);
  }

  static Future<void> deleteToken(FlutterSecureStorage storage) async {
    await storage.delete(key: _tokenKey);
  }

  static Future<String?> readToken(FlutterSecureStorage storage) async {
    return storage.read(key: _tokenKey);
  }
}
