import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local_storage/app_storage.dart';
import '../models/user_model.dart';
import '../network/token_storage.dart';

// ─── CurrentUserNotifier ──────────────────────────────────────────────────────

/// Holds the currently authenticated user for the entire app lifetime.
///
/// - On first access, reads persisted user from [AppStorage].
/// - [setUser]   → called by AuthNotifier after successful login.
/// - [clearUser] → called by AuthNotifier on logout.
///
/// Eagerly initialized in main.dart so the router never sees a stale state.
class CurrentUserNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    print('[CurrentUserProvider] Initializing...');
    final user = await ref.read(appStorageProvider).readUser();
    print('[CurrentUserProvider] Loaded user: ${user?.email}');

    // Eagerly re-hydrate authTokenProvider on startup
    final token = await ref.read(appStorageProvider).readToken();
    if (token != null) {
      ref.read(authTokenProvider.notifier).setToken(token);
    }

    return user;
  }

  Future<void> setUser(AppUser user) async {
    await ref.read(appStorageProvider).saveUser(user);
    state = AsyncData(user);
  }

  Future<void> clearUser() async {
    await ref.read(appStorageProvider).clearAll();
    state = const AsyncData(null);
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, AppUser?>(
  CurrentUserNotifier.new,
);
