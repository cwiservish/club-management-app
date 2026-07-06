// ignore_for_file: constant_identifier_names
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const profileDetail = '/profile-detail';

  static const settings = '/settings';
  static const statistics = '/statistics';
  static const photos = '/photos';
  static const files = '/files';
  static const tracking = '/tracking';
  static const notificationPreferences = '/notification-preferences';
  static const invoicing = '/invoicing';
  static const invoicingNew = 'new';

  static const schedule = '/schedule';
  static const scheduleLeagueDetail = 'league/detail';
  static const scheduleEventDetail = 'event/detail';
  static const scheduleEventForm = 'event/edit';

  static const roster = '/roster';
  static const rosterDetail     = 'detail';
  static const rosterAttendance = 'attendance';

  static const messages = '/messages';
  static const messagesChatDetail = 'chat';
  static const createChannel = 'create-channel';
  static const editChannel = 'edit-channel';

  // Event detail (independent feature)
  static const eventDetailBase = '/event/:eventId';
  static const eventDetailDetails      = 'details';
  static const eventDetailAvailability = 'availability';

  static const eventDetailEdit = 'edit';
  static const newEvent = '/event/new-event';
  static const importSchedule = '/event/import-schedule';

  static String eventDetails(String id)      => '/event/$id/details';
  static String eventAvailability(String id) => '/event/$id/availability';
  static String eventEdit(String id)         => '/event/$id/edit';
}
