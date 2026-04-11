import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Pretty-prints every request, response, and error to the debug console.
/// Completely silent in release/profile builds ([kDebugMode] guard).
///
/// Output format:
/// ```
/// ┌── [→] POST https://api.playbook365.com/v1/auth/login
/// │   Headers: {Content-Type: application/json}
/// │   Body:    {email: "coach@club.com"}
/// └──────────────────────────────────────────────────────
///
/// ┌── [←] 200 POST /auth/login  (142ms)
/// └──────────────────────────────────────────────────────
///
/// ┌── [✗] 401 GET /roster  (88ms)
/// │   DioExceptionType.badResponse
/// └──────────────────────────────────────────────────────
/// ```
class LoggingInterceptor extends Interceptor {
  static final _divider = '─' * 54;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌── [→] ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        debugPrint('│   Headers: ${_sanitiseHeaders(options.headers)}');
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('│   Query:   ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('│   Body:    ${options.data}');
      }
      debugPrint('└$_divider');
    }
    // Store request timestamp for elapsed-time logging.
    options.extra['_requestTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final elapsed = _elapsed(response.requestOptions);
      debugPrint(
        '┌── [←] ${response.statusCode} '
        '${response.requestOptions.method} '
        '${response.requestOptions.path}'
        '${elapsed != null ? '  (${elapsed}ms)' : ''}',
      );
      debugPrint('└$_divider');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final elapsed = _elapsed(err.requestOptions);
      debugPrint(
        '┌── [✗] ${err.response?.statusCode ?? 'N/A'} '
        '${err.requestOptions.method} '
        '${err.requestOptions.path}'
        '${elapsed != null ? '  (${elapsed}ms)' : ''}',
      );
      debugPrint('│   ${err.type.name}: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('│   Response: ${err.response?.data}');
      }
      debugPrint('└$_divider');
    }
    handler.next(err);
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  int? _elapsed(RequestOptions options) {
    final start = options.extra['_requestTime'] as int?;
    if (start == null) return null;
    return DateTime.now().millisecondsSinceEpoch - start;
  }

  /// Redacts the Authorization header value so tokens never appear in logs.
  Map<String, dynamic> _sanitiseHeaders(Map<String, dynamic> headers) {
    return {
      for (final e in headers.entries)
        e.key: e.key.toLowerCase() == 'authorization' ? 'Bearer [redacted]' : e.value,
    };
  }
}
