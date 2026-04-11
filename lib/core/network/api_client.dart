import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/network_exception.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'token_storage.dart';

// ─── ApiClient ────────────────────────────────────────────────────────────────

/// Pure transport layer — sends HTTP requests and returns decoded JSON.
///
/// Responsibilities:
///   - Execute GET / POST / PUT / PATCH / DELETE via Dio
///   - Unwrap the API envelope  `{ success, message, data }` → return `data`
///   - Convert [DioException] → typed [ApiException] (via [ErrorInterceptor])
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
/// final json = await _client.get(ApiEndpoints.roster) as List;
/// return json.map((e) => RosterMember.fromJson(e as Map<String, dynamic>)).toList();
///
/// // Single object
/// final json = await _client.get(ApiEndpoints.rosterMember(id)) as Map<String, dynamic>;
/// return RosterMember.fromJson(json);
///
/// // Create
/// final json = await _client.post(ApiEndpoints.events, body: payload) as Map<String, dynamic>;
/// return ClubEvent.fromJson(json);
/// ```
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  // ─── GET ──────────────────────────────────────────────────────────────────

  /// Returns the decoded `data` value from the API envelope.
  /// Callers cast to `Map<String, dynamic>` or `List` as appropriate.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  // ─── POST ─────────────────────────────────────────────────────────────────

  Future<dynamic> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        cancelToken: cancelToken,
        options: options,
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────

  Future<dynamic> put(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: body,
        cancelToken: cancelToken,
        options: options,
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  // ─── PATCH ────────────────────────────────────────────────────────────────

  Future<dynamic> patch(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: body,
        cancelToken: cancelToken,
        options: options,
      );
      return _unwrap(response.data);
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

  /// Unwraps the standard API envelope.
  /// If the response has a `data` key, returns its value.
  /// Otherwise returns the raw body as-is (handles non-standard endpoints).
  dynamic _unwrap(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// Extracts the [NetworkException] placed by [ErrorInterceptor].
  NetworkException _extractException(DioException e) {
    final error = e.error;
    if (error is NetworkException) return error;
    // Fallback — should not happen if ErrorInterceptor is in the chain.
    return const NetworkException('Something went wrong.');
  }
}

// ─── Riverpod provider ────────────────────────────────────────────────────────

/// Interceptor order:
///   1. [AuthInterceptor]    — attaches Bearer token; clears it on 401
///   2. [LoggingInterceptor] — pretty-prints in debug mode only
///   3. [ErrorInterceptor]   — DioException → ApiException (must be last)
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
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
    LoggingInterceptor(),
    ErrorInterceptor(),
  ]);

  return ApiClient(dio);
});
