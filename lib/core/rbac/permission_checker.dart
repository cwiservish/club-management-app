import '../enums/user_role.dart';

// ─── Permission Enum ──────────────────────────────────────────────────────────

enum Permission {
  // Schedule
  viewSchedule,
  createEvent,
  editEvent,
  deleteEvent,

  // Roster
  viewRoster,
  addPlayer,
  editPlayer,
  removePlayer,
  viewAttendance,
  markAttendance,

  // Messages
  viewMessages,
  sendMessage,

  // Finance
  viewInvoices,
  manageInvoices,

  // Team
  viewTeamDetail,
  editTeamDetail,

  // Statistics / Media / Files
  viewStatistics,
  viewPhotos,
  viewFiles,
  uploadFiles,

  // Registration
  viewRegistration,
  manageRegistration,

  // Tracking
  viewTracking,

  // Preferences
  manageNotificationPrefs,

  // Admin-only
  manageUsers,
}

// ─── Permission Matrix ────────────────────────────────────────────────────────

const _parentPermissions = {
  Permission.viewSchedule,
  Permission.viewRoster,
  Permission.viewMessages,
  Permission.sendMessage,
  Permission.viewInvoices,
  Permission.viewTeamDetail,
  Permission.viewStatistics,
  Permission.viewPhotos,
  Permission.viewFiles,
  Permission.viewRegistration,
  Permission.viewTracking,
  Permission.viewAttendance,
  Permission.manageNotificationPrefs,
};

// Athletes share the same view-only set as parents for now.
const _athletePermissions = _parentPermissions;

const _coachPermissions = {
  ..._parentPermissions,
  Permission.createEvent,
  Permission.editEvent,
  Permission.deleteEvent,
  Permission.addPlayer,
  Permission.editPlayer,
  Permission.removePlayer,
  Permission.markAttendance,
  Permission.manageInvoices,
  Permission.editTeamDetail,
  Permission.uploadFiles,
  Permission.manageRegistration,
};

// Admin gets everything.
const _adminPermissions = {
  ...Permission.values,
};

// ─── PermissionChecker ───────────────────────────────────────────────────────

/// Stateless helper — no Riverpod dependency.
/// Use directly from business logic or pass role explicitly in tests.
///
/// Example:
/// ```dart
/// final canEdit = PermissionChecker.hasPermission(user.role, Permission.editEvent);
/// ```
abstract class PermissionChecker {
  PermissionChecker._();

  static Set<Permission> permissionsFor(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return _parentPermissions;
      case UserRole.athlete:
        return _athletePermissions;
      case UserRole.coach:
        return _coachPermissions;
      case UserRole.admin:
        return _adminPermissions;
    }
  }

  static bool hasPermission(UserRole role, Permission permission) =>
      permissionsFor(role).contains(permission);

  /// Convenience: returns true if the role has ALL of the given permissions.
  static bool hasAll(UserRole role, Iterable<Permission> permissions) =>
      permissions.every((p) => hasPermission(role, p));

  /// Convenience: returns true if the role has ANY of the given permissions.
  static bool hasAny(UserRole role, Iterable<Permission> permissions) =>
      permissions.any((p) => hasPermission(role, p));
}
