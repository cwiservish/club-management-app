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
      debugPrint('┌── [→] Request: ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        debugPrint('│   Headers:');
        _sanitiseHeaders(options.headers).forEach((key, value) {
          debugPrint('│     $key: $value');
        });
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('│   Query Parameters:');
        options.queryParameters.forEach((key, value) {
          debugPrint('│     $key: $value');
        });
      }
      if (options.data != null) {
        debugPrint('│   Request Body (JSON):');
        final formattedBody = _formatJson(options.data);
        for (final line in formattedBody.split('\n')) {
          debugPrint('│     $line');
        }
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
        '┌── [←] Response: ${response.statusCode} '
        '${response.requestOptions.method} '
        '${response.requestOptions.path}'
        '${elapsed != null ? '  (${elapsed}ms)' : ''}',
      );
      if (response.data != null) {
        debugPrint('│   Response Body (JSON):');
        final formattedBody = _formatJson(response.data);
        for (final line in formattedBody.split('\n')) {
          debugPrint('│     $line');
        }
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
        '┌── [✗] Error: ${err.response?.statusCode ?? 'N/A'} '
        '${err.requestOptions.method} '
        '${err.requestOptions.path}'
        '${elapsed != null ? '  (${elapsed}ms)' : ''}',
      );
      debugPrint('│   ${err.type.name}: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('│   Response Body (JSON):');
        final formattedBody = _formatJson(err.response?.data);
        for (final line in formattedBody.split('\n')) {
          debugPrint('│     $line');
        }
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

  /// Format data into a pretty JSON string
  String _formatJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      if (data is String) {
        final decoded = json.decode(data);
        return encoder.convert(decoded);
      }
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
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
}
