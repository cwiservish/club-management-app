import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/statistics_data.dart';
import '../services/statistics_service.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) => StatisticsService());

final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  return ref.read(statisticsServiceProvider).getStatistics();
});
