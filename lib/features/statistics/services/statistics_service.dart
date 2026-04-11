import '../models/statistics_data.dart';

class StatisticsService {
  StatisticsData getStatistics() => const StatisticsData(
        teamCards: [
          TeamStatCard(title: 'Season Record', stats: [
            TeamStat(label: 'Wins', value: '8', colorValue: 0xFF10B981),
            TeamStat(label: 'Losses', value: '2', colorValue: 0xFFEF4444),
            TeamStat(label: 'Draws', value: '1', colorValue: 0xFFF59E0B),
            TeamStat(label: 'Win Rate', value: '73%', colorValue: 0xFF1A56DB),
          ]),
          TeamStatCard(title: 'Goals', stats: [
            TeamStat(label: 'Scored', value: '27', colorValue: 0xFF10B981),
            TeamStat(label: 'Conceded', value: '11', colorValue: 0xFFEF4444),
            TeamStat(label: 'Difference', value: '+16', colorValue: 0xFF1A56DB),
            TeamStat(label: 'Per Game Avg', value: '2.45', colorValue: 0xFF8B5CF6),
          ]),
          TeamStatCard(title: 'Discipline', stats: [
            TeamStat(label: 'Yellow Cards', value: '9', colorValue: 0xFFF59E0B),
            TeamStat(label: 'Red Cards', value: '1', colorValue: 0xFFEF4444),
          ]),
        ],
        players: [
          PlayerStat(name: 'James Miller', position: '#9 FWD', goals: 9, assists: 4, yellowCards: 3),
          PlayerStat(name: 'Oliver Davis', position: '#10 MID', goals: 5, assists: 8, yellowCards: 0),
          PlayerStat(name: 'Lucas Wilson', position: '#11 FWD', goals: 6, assists: 3, yellowCards: 1),
          PlayerStat(name: 'Henry Thomas', position: '#6 MID', goals: 4, assists: 6, yellowCards: 0),
          PlayerStat(name: 'Ethan Brown', position: '#5 DEF', goals: 2, assists: 2, yellowCards: 1),
        ],
      );
}
