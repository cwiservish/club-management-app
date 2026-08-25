import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../../core/local_storage/app_storage.dart';
import '../../../core/common_providers/current_user_provider.dart';
import '../../../core/common_providers/user_teams_provider.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/models/team_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/interceptors/logging_interceptor.dart';
import '../../../core/network/token_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final timeout = Duration(seconds: EnvironmentConfig.timeoutSeconds);
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.fusionAuthBaseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    ),
  );
  if (EnvironmentConfig.enableLogging) {
    dio.interceptors.add(LoggingInterceptor());
  }
  return AuthService(dio);
});

// ─── Login ────────────────────────────────────────────────────────────────────

class LoginNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final (:user, :token) = await ref.read(authServiceProvider).login(email, password);

      await ref.read(appStorageProvider).saveToken(token);
      ref.read(authTokenProvider.notifier).setToken(token);
      await ref.read(currentUserProvider.notifier).setUser(user);

      try {
        final res = await ref.read(apiClientProvider).post(
          ApiEndpoints.clubTeamsList,
          body: '',
          options: Options(contentType: 'application/x-www-form-urlencoded'),
        );
        final grid = ((res.data as Map<String, dynamic>?)?['grid'] as List?) ?? [];
        final teams = grid.map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
        await ref.read(appStorageProvider).saveTeams(teams);
        ref.invalidate(userTeamsProvider);
      } catch (e) {
        debugPrint('[LoginNotifier] Failed to load user teams on login: $e');
      }
    });
  }
}

final loginProvider = AsyncNotifierProvider<LoginNotifier, void>(
  LoginNotifier.new,
);

// ─── Forgot Password ──────────────────────────────────────────────────────────

class ForgotPasswordNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> forgotPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).forgotPassword(email);
    });
  }
}

final forgotPasswordProvider = AsyncNotifierProvider<ForgotPasswordNotifier, void>(
  ForgotPasswordNotifier.new,
);

// ─── Logout ───────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).logout();
      await ref.read(currentUserProvider.notifier).clearUser();
      ref.read(authTokenProvider.notifier).setToken(null);
      ref.invalidate(userTeamsProvider);
    });
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(
  AuthNotifier.new,
);
