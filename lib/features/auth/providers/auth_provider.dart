import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../../core/local_storage/app_storage.dart';
import '../../../core/common_providers/current_user_provider.dart';
import '../../../core/common_providers/user_teams_provider.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/network/interceptors/logging_interceptor.dart';
import '../../../core/network/token_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final timeout = Duration(seconds: EnvironmentConfig.timeoutSeconds);
  final dio = Dio(
    BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    ),
  );

  dio.interceptors.addAll([
    if (EnvironmentConfig.enableLogging) LoggingInterceptor(),
  ]);

  return AuthService(dio, ref.read(appStorageProvider));
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      final user = await authService.login(email, password);
      if (user != null) {
        // Sync token in memory
        final token = await ref.read(appStorageProvider).readToken();
        ref.read(authTokenProvider.notifier).setToken(token);

        await ref.read(currentUserProvider.notifier).setUser(user);
        ref.invalidate(userTeamsProvider);
      } else {
        throw Exception('Login failed: Invalid user data received');
      }
    });
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).forgotPassword(email);
    });
  }

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
