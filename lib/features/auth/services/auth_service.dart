import 'package:dio/dio.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/local_storage/app_storage.dart';
import '../../../core/models/team_model.dart';

class AuthService {
  final Dio _dio;
  final AppStorage _appStorage;

  AuthService(this._dio, this._appStorage);

  Future<List<Team>> fetchTeams(String token) async {
    try {
      final response = await _dio.post(
        'http://qa.playbook365.com/apps/club/teams',
        data: '',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final teamsList = data['data']?['teams'];
          if (teamsList is List) {
            return teamsList
                .map((t) => Team.fromJson(t is Map<String, dynamic> ? t : {}))
                .toList();
          }
          return [];
        } else {
          final msg = data is Map ? data['message'] : null;
          throw msg ?? 'Failed to retrieve teams: success was false';
        }
      } else {
        throw 'Failed to fetch teams from server (status: ${response.statusCode})';
      }
    } on DioException catch (e) {
      throw 'Network error while fetching teams: ${e.message}';
    } catch (e) {
      rethrow;
    }
  }

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
        final token = data['token'] as String?;

        if (token == null) {
          throw 'Login failed: Missing authentication token';
        }

        // Fetch teams and validate the response
        final teams = await fetchTeams(token);

        // Save token and teams locally
        await _appStorage.saveToken(token);
        await _appStorage.saveTeams(teams);

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
      throw e.message ?? 'An error occurred during login';
    } catch (e) {
      rethrow;
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
