import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local_storage/app_storage.dart';
import '../models/user_model.dart';

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
    return ref.read(appStorageProvider).readUser();
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
