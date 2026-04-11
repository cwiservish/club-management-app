class NotificationService {
  Map<String, bool> getDefaultPrefs() => const {
        'Game Reminders': true,
        'Practice Reminders': true,
        'New Messages': true,
        'RSVP Requests': true,
        'Team Announcements': true,
        'Invoice Reminders': false,
        'Photo Uploads': false,
        'File Shares': true,
      };
}
