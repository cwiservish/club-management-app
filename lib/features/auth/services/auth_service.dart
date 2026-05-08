import 'package:dio/dio.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/models/user_model.dart';
import '../../../core/enums/user_role.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AppUser?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '${EnvironmentConfig.fusionAuthBaseUrl}/api/login',
        data: {
          'loginId': email,
          'password': password,
          'applicationId': EnvironmentConfig.fusionAuthAppId,
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

      if (response.statusCode == 200) {
        final data = response.data;
        final user = data['user'];
        
        // Map FusionAuth user to AppUser
        // In a real app, you'd extract roles from FusionAuth registrations
        return AppUser(
          id: user['id'],
          displayName: user['firstName'] ?? user['email'],
          email: user['email'],
          role: UserRole.athlete, // Default role, should be mapped from FusionAuth
          teamId: null,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'User not found or invalid credentials';
      }
      throw 'Login failed: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
    return null;
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        '${EnvironmentConfig.fusionAuthBaseUrl}/api/user/forgot-password',
        data: {
          'loginId': email,
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
    } on DioException catch (e) {
      throw 'Failed to send reset email: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<void> logout() async {
    // Implement FusionAuth logout if needed (e.g. invalidate session)
  }
}
