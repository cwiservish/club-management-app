import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stat.dart';
import '../models/team_stat.dart';
import '../services/statistics_service.dart';

final _statisticsServiceProvider = Provider<StatisticsService>(
  (_) => StatisticsService(),
);

final teamStatsProvider = Provider.autoDispose<List<TeamStat>>((ref) {
  return ref.watch(_statisticsServiceProvider).getTeamStats();
});

final topPerformersProvider = Provider.autoDispose<List<PlayerStat>>((ref) {
  return ref.watch(_statisticsServiceProvider).getTopPerformers();
});
