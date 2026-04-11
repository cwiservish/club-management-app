import '../models/home_data.dart';

class HomeService {
  HomeData getHomeData() {
    return const HomeData(
      stats: HomeStats(
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
        HomeEvent(
          title: 'vs. Riverside FC',
          subtitle: 'U14 Boys — Home Game',
          date: 'Sat, Mar 29',
          time: '10:00 AM',
          type: 'game',
        ),
        HomeEvent(
          title: 'Team Practice',
          subtitle: 'U14 Boys — Field 3',
          date: 'Wed, Mar 26',
          time: '5:30 PM',
          type: 'practice',
        ),
        HomeEvent(
          title: 'vs. Eagles SC',
          subtitle: 'U14 Boys — Away Game',
          date: 'Sat, Apr 5',
          time: '2:00 PM',
          type: 'game',
        ),
      ],
      announcements: [
        HomeAnnouncement(
          message: 'Reminder: Bring your shin guards and cleats to practice tomorrow.',
          author: 'Coach Martinez',
          timeAgo: '2h ago',
          avatarInitials: 'CM',
        ),
        HomeAnnouncement(
          message: 'Registration deadline for the spring tournament is this Friday!',
          author: 'Club Admin',
          timeAgo: '1d ago',
          avatarInitials: 'CA',
        ),
      ],
    );
  }
}
