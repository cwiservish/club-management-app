import 'dart:convert';
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
/// │   Body:    {user: {id: 1, email: "coach@club.com"}}
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
        debugPrint('│   Body:    ${_sanitiseBody(options.data)}');
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
      if (response.data != null) {
        debugPrint('│   Body:    ${_sanitiseBody(response.data)}');
      }
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
        debugPrint('│   Response: ${_sanitiseBody(err.response?.data)}');
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
        e.key: e.key.toLowerCase() == 'authorization'
            ? (e.value.toString().startsWith('Bearer ') ? 'Bearer [redacted]' : '[redacted]')
            : e.value,
    };
  }

  /// Recursively redacts sensitive keys like password, token, secret.
  Object? _sanitiseBody(Object? data) {
    if (data is Map) {
      return {
        for (final e in data.entries)
          e.key.toString().toLowerCase().contains('password') ||
                  e.key.toString().toLowerCase().contains('secret') ||
                  e.key.toString().toLowerCase().contains('token')
              ? e.key: '[redacted]'
              : e.value is Map || e.value is List ? _sanitiseBody(e.value) : e.value,
      };
    }
    if (data is List) {
      return data.map((item) => _sanitiseBody(item)).toList();
    }
    if (data is String) {
      try {
        final decoded = json.decode(data);
        if (decoded is Map || decoded is List) {
          return json.encode(_sanitiseBody(decoded));
        }
      } catch (_) {}
    }
    return data;
  }
}
