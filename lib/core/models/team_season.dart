class TeamSeason {
  final int wins;
  final int losses;
  final int draws;
  final int goalsFor;
  final int goalsAgainst;
  final int rank;
  final String seasonName;
  final String teamName;
  final String division;

  const TeamSeason({
    required this.wins,
    required this.losses,
    required this.draws,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.rank,
    required this.seasonName,
    required this.teamName,
    required this.division,
  });

  int get totalGames => wins + losses + draws;
  int get goalDifference => goalsFor - goalsAgainst;
  double get winRate => totalGames == 0 ? 0 : wins / totalGames;
  int get points => (wins * 3) + draws;
}
