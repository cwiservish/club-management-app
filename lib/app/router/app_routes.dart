abstract class AppRoutes {
  static const splash = '/';
  static const home = '/home';

  static const settings = '/settings';

  static const schedule = '/schedule';
  static const scheduleEventDetail = 'event/detail';
  static const scheduleEventForm = 'event/edit';

  static const roster = '/roster';
  static const rosterAttendance = 'attendance';

  static const messages = '/messages';
  static const messagesChatDetail = 'chat';

  // Event detail (navigated to from HomeCard)
  static const eventDetailBase = 'event/:eventId';
  static const eventDetailDetails      = 'details';
  static const eventDetailAvailability = 'availability';
  static const eventDetailAssignments  = 'assignments';

  static String eventDetails(String id)      => '/home/event/$id/details';
  static String eventAvailability(String id) => '/home/event/$id/availability';
  static String eventAssignments(String id)  => '/home/event/$id/assignments';
}
