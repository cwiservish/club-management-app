import 'package:dio/dio.dart';

/// Manages named [CancelToken]s so in-flight requests can be cancelled
/// cleanly — for example when a Notifier is disposed or a user navigates away.
///
/// Typical usage inside a [Notifier] or [StateNotifier]:
///
/// ```dart
/// class RosterNotifier extends Notifier<RosterState> {
///   final _tokens = CancelTokenRegistry();
///
///   Future<void> load() async {
///     final token = _tokens.get('load');
///     try {
///       final data = await ref.read(rosterServiceProvider).fetchRoster(cancelToken: token);
///       state = RosterState.data(data);
///     } on CancelledException {
///       // navigation moved away — ignore
///     }
///   }
///
///   @override
///   void dispose() {
///     _tokens.cancelAll();
///     super.dispose();
///   }
/// }
/// ```
class CancelTokenRegistry {
  final _tokens = <String, CancelToken>{};

  /// Returns the active [CancelToken] for [key].
  /// Creates a fresh token if none exists or the previous one was already cancelled.
  CancelToken get(String key) {
    final existing = _tokens[key];
    if (existing != null && !existing.isCancelled) return existing;
    final token = CancelToken();
    _tokens[key] = token;
    return token;
  }

  /// Cancels the token registered under [key] and removes it.
  /// No-op if the key does not exist.
  void cancel(String key, [Object? reason]) {
    final token = _tokens.remove(key);
    if (token != null && !token.isCancelled) {
      token.cancel(reason);
    }
  }

  /// Cancels ALL active tokens. Call this from [Notifier.dispose].
  void cancelAll([Object? reason]) {
    for (final token in _tokens.values) {
      if (!token.isCancelled) token.cancel(reason);
    }
    _tokens.clear();
  }

  /// Whether a non-cancelled token exists for [key].
  bool isActive(String key) {
    final token = _tokens[key];
    return token != null && !token.isCancelled;
  }
}
