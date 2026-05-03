import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size:  48,
            color: AppColors.current.textPrimary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'No events yet',
            style: AppTextStyles.body16.copyWith(
              color: AppColors.current.textPrimary.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
