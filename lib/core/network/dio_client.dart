import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_endpoints.dart';
import 'auth_interceptor.dart';

/// Factory that builds and configures the singleton [Dio] instance.
class DioClient {
  DioClient._();

  static Dio create(FlutterSecureStorage storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Always add auth interceptor.
    dio.interceptors.add(AuthInterceptor(storage));

    // Pretty-print logs only in debug builds.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }
}
