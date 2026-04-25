import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../models/player_stat.dart';
import '../models/team_stat.dart';

class StatisticsService {
  List<TeamStat> getTeamStats() {
    return [
      TeamStat(
        label: 'Matches Played',
        value: '25',
        iconAsset: AppAssets.activityIcon,
        iconColor: AppColors.current.primary,
      ),
      TeamStat(
        label: 'Goals Scored',
        value: '42',
        iconAsset: AppAssets.goalIcon,
        iconColor: AppColors.current.primary,
      ),
      TeamStat(
        label: 'Wins',
        value: '13',
        iconAsset: AppAssets.trophyIcon,
        iconColor: AppColors.current.rsvpGoing,
      ),
      TeamStat(
        label: 'Draws',
        value: '3',
        iconAsset: AppAssets.activityIcon,
        iconColor: AppColors.current.rsvpMaybe,
      ),
      TeamStat(
        label: 'Losses',
        value: '9',
        iconAsset: AppAssets.activityIcon,
        iconColor: AppColors.current.rsvpNo,
      ),
    ];
  }

  List<PlayerStat> getTopPerformers() {
    return const [
      PlayerStat(name: 'Kinsley Weston', goals: 12, assists: 4),
      PlayerStat(name: 'Mila Chaisson', goals: 8, assists: 6),
      PlayerStat(name: 'Scarlett Garling', goals: 5, assists: 11),
      PlayerStat(name: 'Kinley Kirkes', goals: 4, assists: 2),
    ];
  }
}
