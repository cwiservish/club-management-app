import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../common_providers/current_user_provider.dart';
import '../config/environment_config.dart';
import '../exceptions/network_exception.dart';
import '../utils/navigator_key.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'models/api_response.dart';
import 'token_storage.dart';

// ─── ApiClient ────────────────────────────────────────────────────────────────

/// Pure transport layer — sends HTTP requests and returns [ApiResponse].
///
/// Responsibilities:
///   - Execute GET / POST / PUT / PATCH / DELETE via Dio
///   - Wrap the raw response in [ApiResponse] — exposes data, message, success
///   - Convert [DioException] → [NetworkException] (via [ErrorInterceptor])
///   - Forward [CancelToken] from the calling service
///
/// What it does NOT do:
///   - Map JSON → domain models  (that belongs in each feature's Service)
///   - Contain business logic
///   - Know about any feature
///
/// Usage in a service:
/// ```dart
/// // List
/// final res = await _client.get(ApiEndpoints.roster);
/// return (res.data as List).map((e) => RosterMember.fromJson(e)).toList();
///
/// // Single object
/// final res = await _client.get(ApiEndpoints.rosterMember(id));
/// return RosterMember.fromJson(res.data as Map<String, dynamic>);
///
/// // Create
/// final res = await _client.post(ApiEndpoints.events, body: payload);
/// return ClubEvent.fromJson(res.data as Map<String, dynamic>);
/// ```
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  // ─── Path Helper ──────────────────────────────────────────────────────────

  String _cleanPath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return path.startsWith('/') ? path.substring(1) : path;
  }

  // ─── GET ──────────────────────────────────────────────────────────────────

  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _cleanPath(path),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return ApiResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  // ─── POST ─────────────────────────────────────────────────────────────────

  Future<ApiResponse> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _cleanPath(path),
        data: body,
        cancelToken: cancelToken,
        options: options,
      );
      return ApiResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────

  Future<ApiResponse> put(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        _cleanPath(path),
        data: body,
        cancelToken: cancelToken,
        options: options,
      );
      return ApiResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  // ─── PATCH ────────────────────────────────────────────────────────────────

  Future<ApiResponse> patch(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        _cleanPath(path),
        data: body,
        cancelToken: cancelToken,
        options: options,
      );
      return ApiResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<void> delete(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      await _dio.delete<void>(
        _cleanPath(path),
        data: body,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  NetworkException _extractException(DioException e) {
    final error = e.error;
    if (error is NetworkException) return error;
    return const NetworkException('Something went wrong.');
  }
}

// ─── Riverpod provider ────────────────────────────────────────────────────────

/// Interceptor order:
///   1. [AuthInterceptor]    — attaches Bearer token; clears it on 401
///   2. [LoggingInterceptor] — pretty-prints in debug mode only
///   3. [ErrorInterceptor]   — DioException → NetworkException (must be last)
final apiClientProvider = Provider<ApiClient>((ref) {
  final timeout = Duration(seconds: EnvironmentConfig.timeoutSeconds);
  final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
      ? ApiEndpoints.baseUrl
      : '${ApiEndpoints.baseUrl}/';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(
      getToken: () async => ref.read(authTokenProvider),
      onUnauthorized: () async {
        final isLoggedIn = ref.read(currentUserProvider).value != null;
        if (isLoggedIn) {
          ref.read(authTokenProvider.notifier).setToken(null);
          await ref.read(currentUserProvider.notifier).clearUser();
          _showSessionExpiredDialog();
        }
      },
    ),
    if (EnvironmentConfig.enableLogging) LoggingInterceptor(),
    ErrorInterceptor(),
  ]);

  return ApiClient(dio);
});

// ─── Session Expired Dialog Helper ──────────────────────────────────────────

bool _isSessionExpiredShowing = false;

void _showSessionExpiredDialog() {
  if (_isSessionExpiredShowing) return;

  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    debugPrint('[AuthInterceptor] Cannot show session expired dialog: context is null');
    return;
  }

  _isSessionExpiredShowing = true;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final colors = AppColors.current;
      return AlertDialog(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Session Expired',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Please login again.',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 15,
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('OK'),
            onPressed: () {
              _isSessionExpiredShowing = false;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
