import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import 'permission_checker.dart';

/// Conditionally renders [child] based on whether the current user holds
/// the required [permission].
///
/// If the user is unauthenticated or lacks the permission, [fallback] is
/// shown instead (defaults to an empty box).
///
/// Example — hide the "Add Player" button from parents:
/// ```dart
/// RoleGuard(
///   permission: Permission.addPlayer,
///   child: ElevatedButton(onPressed: _addPlayer, child: Text('Add Player')),
/// )
/// ```
///
/// Example — show a read-only banner for athletes:
/// ```dart
/// RoleGuard(
///   permission: Permission.editEvent,
///   fallback: ReadOnlyBanner(),
///   child: EditEventButton(),
/// )
/// ```
class RoleGuard extends ConsumerWidget {
  final Permission permission;
  final Widget child;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null || !PermissionChecker.hasPermission(user.role, permission)) {
      return fallback ?? const SizedBox.shrink();
    }

    return child;
  }
}

/// Multi-permission variant — shows [child] only when the user holds
/// ALL of [permissions].
class RoleGuardAll extends ConsumerWidget {
  final List<Permission> permissions;
  final Widget child;
  final Widget? fallback;

  const RoleGuardAll({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null || !PermissionChecker.hasAll(user.role, permissions)) {
      return fallback ?? const SizedBox.shrink();
    }

    return child;
  }
}
