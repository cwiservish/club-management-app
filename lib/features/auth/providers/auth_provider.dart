import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/user_role.dart';
import '../../../core/models/user_model.dart';

/// Sample authenticated user — matches the "Jamie Davis / Parent" persona
/// used throughout the design. Replace with real auth once backend is wired.
const _sampleUser = AppUser(
  id: 'u1',
  displayName: 'Jamie Davis',
  email: 'jamie.davis@email.com',
  role: UserRole.parent,
  teamId: 'team_u14_boys',
);

/// Manages the currently signed-in user.
///
/// `state == null` means unauthenticated (reserved for the login flow).
/// Call [setUser] after a successful sign-in, [signOut] to clear.
class CurrentUserNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => _sampleUser;

  void setUser(AppUser user) => state = user;
  void signOut() => state = null;
}

/// The currently signed-in user.
///
/// Read in widgets via `ref.watch(currentUserProvider)`.
/// Write via `ref.read(currentUserProvider.notifier).setUser(...)`.
final currentUserProvider = NotifierProvider<CurrentUserNotifier, AppUser?>(
  CurrentUserNotifier.new,
);
