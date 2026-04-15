import '../models/settings_data.dart';

class SettingsService {
  SettingsData getSettingsData() {
    return const SettingsData(
      stats: SettingsStats(
        playerCount: 18,
        eventsThisWeek: 3,
        messageCount: 5,
        wins: 8,
        losses: 2,
        draws: 1,
        rank: '3rd',
        teamName: 'U14 Boys Premier',
        season: 'Spring Season 2025',
      ),
      events: [
        SettingsEvent(
          title: 'vs. Riverside FC',
          subtitle: 'U14 Boys — Home Game',
          date: 'Sat, Mar 29',
          time: '10:00 AM',
          type: 'game',
        ),
        SettingsEvent(
          title: 'Team Practice',
          subtitle: 'U14 Boys — Field 3',
          date: 'Wed, Mar 26',
          time: '5:30 PM',
          type: 'practice',
        ),
        SettingsEvent(
          title: 'vs. Eagles SC',
          subtitle: 'U14 Boys — Away Game',
          date: 'Sat, Apr 5',
          time: '2:00 PM',
          type: 'game',
        ),
      ],
      announcements: [
        SettingsAnnouncement(
          message: 'Reminder: Bring your shin guards and cleats to practice tomorrow.',
          author: 'Coach Martinez',
          timeAgo: '2h ago',
          avatarInitials: 'CM',
        ),
        SettingsAnnouncement(
          message: 'Registration deadline for the spring tournament is this Friday!',
          author: 'Club Admin',
          timeAgo: '1d ago',
          avatarInitials: 'CA',
        ),
      ],
    );
  }
}
