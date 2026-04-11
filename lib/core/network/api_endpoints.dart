import '../config/environment_config.dart';

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

  static final String baseUrl = EnvironmentConfig.baseUrl;

  // ─── Auth ──────────────────────────────────────────────────────────────────

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  // ─── Team ──────────────────────────────────────────────────────────────────

  static const String teams = '/teams';
  static String team(String id) => '/teams/$id';
  static String teamMembers(String teamId) => '/teams/$teamId/members';
  static String teamStats(String teamId) => '/teams/$teamId/stats';

  // ─── Roster ────────────────────────────────────────────────────────────────

  static const String roster = '/roster';
  static String rosterMember(String id) => '/roster/$id';
  static String rosterMemberAttendance(String id) => '/roster/$id/attendance';
  static String rosterMemberStats(String id) => '/roster/$id/stats';

  // ─── Schedule / Events ────────────────────────────────────────────────────

  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String eventAttendees(String id) => '/events/$id/attendees';
  static String eventAttendance(String id) => '/events/$id/attendance';

  // ─── Messages ─────────────────────────────────────────────────────────────

  static const String threads = '/messages/threads';
  static String thread(String id) => '/messages/threads/$id';
  static String threadMessages(String id) => '/messages/threads/$id/messages';
  static String message(String threadId, String messageId) =>
      '/messages/threads/$threadId/messages/$messageId';
  static const String unreadCount = '/messages/unread-count';

  // ─── Statistics ────────────────────────────────────────────────────────────

  static const String statistics = '/statistics';
  static String playerStatistics(String playerId) => '/statistics/players/$playerId';

  // ─── Photos ────────────────────────────────────────────────────────────────

  static const String albums = '/photos/albums';
  static String album(String id) => '/photos/albums/$id';
  static String albumPhotos(String albumId) => '/photos/albums/$albumId/photos';
  static String photo(String id) => '/photos/$id';

  // ─── Files ─────────────────────────────────────────────────────────────────

  static const String files = '/files';
  static String file(String id) => '/files/$id';
  static String fileDownload(String id) => '/files/$id/download';

  // ─── Invoicing ─────────────────────────────────────────────────────────────

  static const String invoices = '/invoices';
  static String invoice(String id) => '/invoices/$id';
  static String invoiceMarkPaid(String id) => '/invoices/$id/mark-paid';
  static String memberInvoices(String memberId) => '/roster/$memberId/invoices';

  // ─── Registration ─────────────────────────────────────────────────────────

  static const String registrations = '/registrations';
  static String registration(String id) => '/registrations/$id';
  static String registrationApprove(String id) => '/registrations/$id/approve';
  static String registrationReject(String id) => '/registrations/$id/reject';

  // ─── Tracking ─────────────────────────────────────────────────────────────

  static const String tracking = '/tracking';
  static String trackingGoals(String teamId) => '/tracking/teams/$teamId/goals';

  // ─── Notifications ────────────────────────────────────────────────────────

  static const String notificationPrefs = '/notifications/preferences';
  static const String notificationTokens = '/notifications/tokens';
}
