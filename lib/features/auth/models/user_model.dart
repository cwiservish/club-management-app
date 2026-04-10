import '../../../core/enums/user_role.dart';

/// Authenticated user record.
///
/// [role] drives all permission checks via [PermissionChecker].
/// [teamId] scopes data access to a specific team (null = club-wide admin).
class AppUser {
  final String id;
  final String displayName;
  final String email;
  final UserRole role;
  final String? teamId;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.teamId,
  });

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isCoach => role == UserRole.coach;
  bool get isParent => role == UserRole.parent;
  bool get isAthlete => role == UserRole.athlete;

  AppUser copyWith({
    String? id,
    String? displayName,
    String? email,
    UserRole? role,
    String? teamId,
  }) {
    return AppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
    );
  }
}
