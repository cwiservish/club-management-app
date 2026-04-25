import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/statistics_provider.dart';
import '../widgets/statistics_widgets.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final teamStats = ref.watch(teamStatsProvider);
    final topPerformers = ref.watch(topPerformersProvider);

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(title: 'Statistics'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatisticsTeamSection(stats: teamStats),
                    const SizedBox(height: 24),
                    StatisticsTopPerformersSection(players: topPerformers),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
