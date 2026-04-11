import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment_config.dart';
import '../exceptions/network_exception.dart';
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

  // ─── GET ──────────────────────────────────────────────────────────────────

  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
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
        path,
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
        path,
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
        path,
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
        path,
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

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
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
        ref.read(authTokenProvider.notifier).setToken(null);
      },
    ),
    if (EnvironmentConfig.enableLogging) LoggingInterceptor(),
    ErrorInterceptor(),
  ]);

  return ApiClient(dio);
});
