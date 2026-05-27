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
  static const String baseUrl = 'https://qa.playbook365.com';


  // ─── Team ──────────────────────────────────────────────────────────────────

  static const String clubTeamsList = '/apps/club/teams/list';
  static String teamPlayersList(String teamUuid) => '/apps/club/teams/$teamUuid/players/list';
  static String playerProfile(String teamUuid, String playerUuid) =>
      '/apps/club/teams/$teamUuid/players/$playerUuid/profile';
  static const String assignParent = '/apps/club/players/parents/assign';
  static const String customerNotificationsList = '/apps/club/customer/notifications/list';
  static const String customerNotificationsSave = '/apps/club/customer/notifications/save';

  // ─── Photos / Files ────────────────────────────────────────────────────────
  static const String photosList = '/apps/club/teams/files/list';
  static const String photoSave = '/apps/club/teams/gallery/save';
  static const String photoRemove = '/apps/club/teams/gallery/remove';
  static const String filesList = '/apps/club/teams/files/list';
  static const String filesSave = '/apps/club/teams/files/save';
  static const String filesRemove = '/apps/club/teams/files/remove';
}
