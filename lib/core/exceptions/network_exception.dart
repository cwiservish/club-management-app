import 'app_exception.dart';

/// Thrown by [ApiClient] for every failed HTTP request.
///
/// [statusCode] is null when there is no response at all
/// (no internet, DNS failure, timeout, or a cancelled request).
///
/// [message] is always a short, human-readable string safe to show in the UI.
/// It comes from the API response body when available, otherwise it is derived
/// from [statusCode] — Dio's internal error strings are never used.
///
/// Usage in a service or notifier:
/// ```dart
/// try {
///   final data = await _client.get(ApiEndpoints.roster);
///   ...
/// } on NetworkException catch (e) {
///   if (e.statusCode == 401) { /* redirect to login */ }
///   state = ErrorState(e.message);
/// }
/// ```
class NetworkException extends AppException {
  final int? statusCode;

  const
  NetworkException(super.message, {this.statusCode});

  /// Convenience — true when there was no HTTP response at all.
  bool get isConnectivityError => statusCode == null;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => (statusCode ?? 0) >= 500;

  @override
  String toString() => 'NetworkException($statusCode): $message';
}
