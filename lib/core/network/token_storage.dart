import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory JWT token holder.
///
/// Lives in core/network (NOT in features/auth) to avoid a circular dependency:
///   core/network → features/auth → core/network  ✗
///
/// Flow:
///   1. User logs in  → `ref.read(authTokenProvider.notifier).setToken(token)`
///   2. [AuthInterceptor] calls `ref.read(authTokenProvider)` before every request
///   3. User logs out → `ref.read(authTokenProvider.notifier).setToken(null)`
///
/// Persistence: not persisted here intentionally. Restore from flutter_secure_storage
/// in [AuthNotifier.build] and call [setToken] to re-hydrate on cold start.
class TokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String? token) => state = token;
}

final authTokenProvider = NotifierProvider<TokenNotifier, String?>(
  TokenNotifier.new,
);
