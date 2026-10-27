import 'dart:io';

import 'package:dio/dio.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/models/user_model.dart';
import '../../../core/enums/user_role.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  static const noInternetMessage = 'No internet connection. Check your network and try again.';

  /// No network, DNS failure or a timeout (this Dio has no ErrorInterceptor).
  static bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        (e.type == DioExceptionType.unknown && e.error is SocketException);
  }

  Future<({AppUser user, String token})> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/login',
        data: {
          'loginId': email,
          'password': password,
          // No `applicationId`: login works for any FusionAuth user in the tenant
          // (parents, athletes, managers / organization staff).
        },
        options: Options(
          headers: {
            if (EnvironmentConfig.fusionAuthApiKey.isNotEmpty)
              'Authorization': EnvironmentConfig.fusionAuthApiKey,
            if (EnvironmentConfig.fusionAuthTenantId.isNotEmpty)
              'X-FusionAuth-TenantId': EnvironmentConfig.fusionAuthTenantId,
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null) throw 'Login failed: missing token';

      final rawUser = data['user'] as Map<String, dynamic>;
      final user = AppUser(
        id: rawUser['id'] as String,
        displayName: (rawUser['firstName'] as String?) ?? (rawUser['email'] as String),
        email: rawUser['email'] as String,
        role: UserRole.athlete,
        teamId: null,
      );

      return (user: user, token: token);
    } on DioException catch (e) {
      if (_isNetworkError(e)) throw noInternetMessage;
      if (e.response?.statusCode == 404) throw 'Invalid email or password';
      throw e.message ?? 'Login failed';
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        '/api/user/forgot-password',
        data: {'loginId': email},
        options: Options(
          headers: {
            if (EnvironmentConfig.fusionAuthApiKey.isNotEmpty)
              'Authorization': EnvironmentConfig.fusionAuthApiKey,
            if (EnvironmentConfig.fusionAuthTenantId.isNotEmpty)
              'X-FusionAuth-TenantId': EnvironmentConfig.fusionAuthTenantId,
          },
        ),
      );
    } on DioException catch (e) {
      if (_isNetworkError(e)) throw noInternetMessage;
      throw 'Failed to send reset email: ${e.message}';
    }
  }

  Future<void> logout() async {
    // FusionAuth session invalidation if needed
  }
}
