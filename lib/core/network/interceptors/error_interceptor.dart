import 'package:dio/dio.dart';

import '../../exceptions/network_exception.dart';

/// Converts every [DioException] into a [NetworkException] and rejects
/// the handler so downstream code only ever deals with one exception type.
///
/// Message priority (Dio's own strings are never used — they are too verbose):
///   1. `response.data['message']`  — backend-provided human-readable string
///   2. `response.data['error']`    — alternative backend field
///   3. `response.data['detail']`   — Django / DRF convention
///   4. Short fallback derived from the HTTP status code
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _toNetworkException(err);

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  // ─── Mapping ───────────────────────────────────────────────────────────────

  NetworkException _toNetworkException(DioException err) {
    // Already mapped — a retry interceptor may re-throw a NetworkException.
    if (err.error is NetworkException) return err.error as NetworkException;

    // Request cancelled via CancelToken — treat as a special no-code case.
    if (err.type == DioExceptionType.cancel) {
      return const NetworkException('Request was cancelled.');
    }

    // No internet, DNS failure, or any timeout variant.
    if (_isConnectivityError(err.type)) {
      return const NetworkException('No internet connection.');
    }

    // We have an HTTP response — extract status code and message.
    final statusCode = err.response?.statusCode;
    final serverMessage = _extractServerMessage(err.response?.data);

    return NetworkException(
      serverMessage ?? _fallbackMessage(statusCode),
      statusCode: statusCode,
    );
  }

  bool _isConnectivityError(DioExceptionType type) {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError;
  }

  /// Tries common API message fields in order.
  /// Returns null if none are present or non-empty.
  String? _extractServerMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    for (final key in const ['message', 'error', 'detail']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Short, UI-safe fallback strings — one line, no Dio internals.
  String _fallbackMessage(int? code) {
    return switch (code) {
      400 => 'Bad request.',
      401 => 'Session expired. Please log in again.',
      403 => 'You don\'t have permission to do that.',
      404 => 'Not found.',
      408 => 'Request timed out.',
      409 => 'Conflict. The resource already exists.',
      422 => 'Invalid data submitted.',
      429 => 'Too many requests. Please slow down.',
      500 => 'Server error. Try again later.',
      502 || 503 || 504 => 'Service unavailable. Try again later.',
      _ when (code ?? 0) >= 500 => 'Server error. Try again later.',
      _ => 'Something went wrong.',
    };
  }
}
