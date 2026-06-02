import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/team_model.dart';

class TeamInfoCard extends StatelessWidget {
  final Team? team;

  const TeamInfoCard({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    if (team == null) {
      return Container(
        width: double.infinity,
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.current.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.current.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.current.warning, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'No active team selected',
                style: AppTextStyles.body16.copyWith(
                  color: AppColors.current.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.current.primary.withValues(alpha: 0.15),
                  AppColors.current.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.current.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                team!.name.isNotEmpty ? team!.name[0].toUpperCase() : 'T',
                style: AppTextStyles.heading18.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.current.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team!.name,
                  style: AppTextStyles.body16.copyWith(
                    color: AppColors.current.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
