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
  static const String playerAttendanceHistory = '/team/player/attendance_history';
  static const String assignParent = '/players/parents/assign';
  static const String playerPositions = '/team/player/positions';
  static const String playerSave = '/team/player/save';
  static const String teamEventsList = '/teams/event/session/list';
  static const String teamEventsAll = '/teams/event/all';
  static const String eventAvailability = '/teams/event/availability';
  static const String eventAttendeeSave = '/teams/event-attendee/save';
  static const String eventDropdownOptions = '/teams/event/dropdownoptions';
  static const String newEventDropdownOptions = '/teams/event/session/dropdownoptions';
  static const String eventSave = '/teams/event/save';
  static const String eventRemove = '/teams/event/remove';
  static const String customerNotificationsList = '/customer/notification/list';
  static const String customerNotificationsSave = '/customer/notification/save';

  // ─── Photos / Files ────────────────────────────────────────────────────────
  static const String photosList = '/teams/gallery/list';
  static const String photoSave = '/teams/gallery/save';
  static const String photoRemove = '/teams/gallery/remove';
  static const String filesList = '/teams/file/list';
  static const String filesSave = '/teams/file/save';
  static const String filesRemove = '/teams/file/remove';
}
