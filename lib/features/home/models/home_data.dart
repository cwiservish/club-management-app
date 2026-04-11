class HomeEvent {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String type;

  const HomeEvent({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.type,
  });
}

class HomeAnnouncement {
  final String message;
  final String author;
  final String timeAgo;
  final String avatarInitials;

  const HomeAnnouncement({
    required this.message,
    required this.author,
    required this.timeAgo,
    required this.avatarInitials,
  });
}

class HomeStats {
  final int playerCount;
  final int eventsThisWeek;
  final int messageCount;
  final int wins;
  final int losses;
  final int draws;
  final String rank;
  final String teamName;
  final String season;

  const HomeStats({
    required this.playerCount,
    required this.eventsThisWeek,
    required this.messageCount,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.rank,
    required this.teamName,
    required this.season,
  });
}

class HomeData {
  final HomeStats stats;
  final List<HomeEvent> events;
  final List<HomeAnnouncement> announcements;

  const HomeData({
    required this.stats,
    required this.events,
    required this.announcements,
  });
}
