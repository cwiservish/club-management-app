/// All Playbook365 API endpoint paths.
///
/// Keep every path here — never hardcode strings in services.
/// Parameterised paths are static methods that return the interpolated string.
///
/// Usage:
/// ```dart
/// final path = ApiEndpoints.rosterMember('abc123');   // '/roster/abc123'
/// final path = ApiEndpoints.threadMessages('t1');     // '/messages/threads/t1/messages'
/// ```
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ─── Base ──────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://qa.playbook365.com/apps/club';


  // ─── Team ──────────────────────────────────────────────────────────────────
  static const String clubTeamsList = '/team/list';
  static const String teamPlayersList = '/team/player/list';
  static const String teamStaffList = '/team/staff/list';
  static const String playerProfile = '/team/player/profile';
  static const String assignParent = '/players/parents/assign';
  static const String playerPositions = '/team/player/positions';
  static const String playerSave = '/team/player/save';
  static const String customerNotificationsList = '/customer/notification/list';
  static const String customerNotificationsSave = '/customer/notification/save';

  // ─── Photos / Files ────────────────────────────────────────────────────────
  static const String photosList = '/teams/files/list';
  static const String photoSave = '/teams/gallery/save';
  static const String photoRemove = '/teams/gallery/remove';
  static const String filesList = '/teams/files/list';
  static const String filesSave = '/teams/files/save';
  static const String filesRemove = '/teams/files/remove';
}
