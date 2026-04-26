import '../models/notification_settings.dart';

class NotificationPreferencesService {
  NotificationSettings getDefaults() {
    return const NotificationSettings(
      mobileAlerts: true,
      liveScore: true,
      liveMessages: true,
    );
  }
}
