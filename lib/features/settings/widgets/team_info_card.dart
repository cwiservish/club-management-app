import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class TeamInfoCard extends StatelessWidget {
  final String teamName;
  final String record;

  const TeamInfoCard({
    super.key,
    required this.teamName,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.current.card,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'P',
                style: AppTextStyles.heading18.copyWith(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppColors.current.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(teamName,
                  style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary)),
              const SizedBox(height: 4),
              Text(record,
                  style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
