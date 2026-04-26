abstract class AppRoutes {
  static const splash = '/';
  static const home = '/home';

  static const settings = '/settings';
  static const statistics = '/statistics';
  static const photos = '/photos';
  static const files = '/files';
  static const tracking = '/tracking';
  static const notificationPreferences = '/notification-preferences';
  static const invoiceNew = '/invoice/new';

  static const schedule = '/schedule';
  static const scheduleEventDetail = 'event/detail';
  static const scheduleEventForm = 'event/edit';

  static const roster = '/roster';
  static const rosterDetail     = 'detail';
  static const rosterAttendance = 'attendance';

  static const messages = '/messages';
  static const messagesChatDetail = 'chat';

  // Event detail (independent feature)
  static const eventDetailBase = '/event/:eventId';
  static const eventDetailDetails      = 'details';
  static const eventDetailAvailability = 'availability';
  static const eventDetailAssignments  = 'assignments';

  static const eventDetailEdit = 'edit';

  static String eventDetails(String id)      => '/event/$id/details';
  static String eventAvailability(String id) => '/event/$id/availability';
  static String eventAssignments(String id)  => '/event/$id/assignments';
  static String eventEdit(String id)         => '/event/$id/edit';
}
