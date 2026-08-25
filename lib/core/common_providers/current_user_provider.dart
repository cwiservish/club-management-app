import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local_storage/app_storage.dart';
import '../models/user_model.dart';
import '../network/token_storage.dart';
import 'selected_team_provider.dart';

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
    try {
      debugPrint('[CurrentUserProvider] Initializing...');
      final user = await ref.read(appStorageProvider).readUser();
      final token = await ref.read(appStorageProvider).readToken();
      debugPrint('[CurrentUserProvider] Loaded user: ${user?.email}, token present: ${token != null}');

      if (user != null && token != null && token.isNotEmpty) {
        ref.read(authTokenProvider.notifier).setToken(token);

        final savedUuid = await ref.read(appStorageProvider).readSelectedTeamUuid();
        if (savedUuid != null) {
          SelectedTeamNotifier.setInitialUuid(savedUuid);
        }
        return user;
      }

      if (user != null && (token == null || token.isEmpty)) {
        debugPrint('[CurrentUserProvider] User found without valid token. Clearing session.');
        await ref.read(appStorageProvider).clearAll();
        ref.read(authTokenProvider.notifier).setToken(null);
        return null;
      }

      return user;
    } catch (e, st) {
      debugPrint('[CurrentUserProvider] Error loading persisted user session: $e\n$st');
      return null;
    }
  }

  Future<void> setUser(AppUser user) async {
    await ref.read(appStorageProvider).saveUser(user);
    state = AsyncData(user);
  }

  Future<void> clearUser() async {
    await ref.read(appStorageProvider).clearAll();
    ref.read(selectedTeamProvider.notifier).clearSelectedTeam();
    state = const AsyncData(null);
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, AppUser?>(
  CurrentUserNotifier.new,
);
