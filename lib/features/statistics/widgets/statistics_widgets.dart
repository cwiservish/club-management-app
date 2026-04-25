import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';
import '../models/player_stat.dart';
import '../models/team_stat.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Section Label
// ══════════════════════════════════════════════════════════════════════════════

class StatisticsSectionLabel extends StatelessWidget {
  final String title;
  const StatisticsSectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.heading14.copyWith(
        color: AppColors.current.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Team Overview Grid
// ══════════════════════════════════════════════════════════════════════════════

class StatisticsTeamSection extends StatelessWidget {
  final List<TeamStat> stats;
  const StatisticsTeamSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.85,
          ),
          itemCount: stats.length,
          itemBuilder: (_, i) => StatisticsTeamCard(stat: stats[i]),
        ),
      ],
    );
  }
}

class StatisticsTeamCard extends StatelessWidget {
  final TeamStat stat;
  const StatisticsTeamCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.gray100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  style: AppTextStyles.heading13.copyWith(
                    color: AppColors.current.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              CustomSvgIcon(
                assetPath: stat.iconAsset,
                size: 20,
                color: stat.iconColor,
              ),
            ],
          ),
          Text(
            stat.value,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.current.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Top Performers Table
// ══════════════════════════════════════════════════════════════════════════════

class StatisticsTopPerformersSection extends StatelessWidget {
  final List<PlayerStat> players;
  const StatisticsTopPerformersSection({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatisticsSectionLabel(title: 'Top Performers'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.current.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.current.border.withOpacity(0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
            children: [
              _TableHeader(),
              ...players.map((p) => _PlayerRow(
                    player: p,
                    isLast: p == players.last,
                  )),
            ],
          ),
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.current.card,
      child: Row(
        children: [
          Expanded(
            flex:4,
            child: Text(
              'PLAYER',
              style: AppTextStyles.heading12.copyWith(
                color: AppColors.current.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              width: 40,
              child: Text(
                'G',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading12.copyWith(
                  color: AppColors.current.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,

            child: SizedBox(
              width: 40,
              child: Text(
                'A',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading12.copyWith(
                  color: AppColors.current.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final PlayerStat player;
  final bool isLast;
  const _PlayerRow({required this.player, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.current.gray100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex:4,

            child: Text(
              player.name,
              style: AppTextStyles.body15.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex:1,

            child: Text(
              '${player.goals}',
              textAlign: TextAlign.center,
              style: AppTextStyles.body15.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex:1,
            
            child: Text(
              '${player.assists}',
              textAlign: TextAlign.center,
              style: AppTextStyles.body15.copyWith(
                color: AppColors.current.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
