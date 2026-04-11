import 'package:dio/dio.dart';

/// Attaches the Bearer token to every request and handles 401 responses.
///
/// [getToken] — async callback that returns the current JWT (or null if logged out).
///   Kept as a callback to avoid circular provider dependencies: this interceptor
///   lives in core/network but reads auth state from features/auth via the callback.
///
/// [onUnauthorized] — called when a 401 is received. Typically signs the user out
///   and clears the stored token.
///
/// Token refresh (silent re-auth) is not implemented here intentionally — add a
/// [QueuedInterceptorsWrapper] with a refresh flow when the backend supports it.
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  final Future<void> Function()? onUnauthorized;

  const AuthInterceptor({
    required this.getToken,
    this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints (login, register, etc.)
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}

// ─── Request options helpers ──────────────────────────────────────────────────

extension AuthOptions on Options {
  /// Marks a request as public — the [AuthInterceptor] will not attach a token.
  ///
  /// Usage:
  /// ```dart
  /// _dio.post('/auth/login', data: body, options: Options().skipAuth());
  /// ```
  Options skipAuth() => copyWith(extra: {...?extra, 'skipAuth': true});
}
