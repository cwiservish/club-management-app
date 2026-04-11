class TeamStat {
  final String label;
  final String value;
  final int colorValue;

  const TeamStat({
    required this.label,
    required this.value,
    required this.colorValue,
  });
}

class TeamStatCard {
  final String title;
  final List<TeamStat> stats;

  const TeamStatCard({required this.title, required this.stats});
}

class PlayerStat {
  final String name;
  final String position;
  final int goals;
  final int assists;
  final int yellowCards;

  const PlayerStat({
    required this.name,
    required this.position,
    required this.goals,
    required this.assists,
    required this.yellowCards,
  });
}

class StatisticsData {
  final List<TeamStatCard> teamCards;
  final List<PlayerStat> players;

  const StatisticsData({required this.teamCards, required this.players});
}
