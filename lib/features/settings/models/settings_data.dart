class SettingsEvent {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String type;

  const SettingsEvent({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.type,
  });
}

class SettingsAnnouncement {
  final String message;
  final String author;
  final String timeAgo;
  final String avatarInitials;

  const SettingsAnnouncement({
    required this.message,
    required this.author,
    required this.timeAgo,
    required this.avatarInitials,
  });
}

class SettingsStats {
  final int playerCount;
  final int eventsThisWeek;
  final int messageCount;
  final int wins;
  final int losses;
  final int draws;
  final String rank;
  final String teamName;
  final String season;

  const SettingsStats({
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

class SettingsData {
  final SettingsStats stats;
  final List<SettingsEvent> events;
  final List<SettingsAnnouncement> announcements;

  const SettingsData({
    required this.stats,
    required this.events,
    required this.announcements,
  });
}
