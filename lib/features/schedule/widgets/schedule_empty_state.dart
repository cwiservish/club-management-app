import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class ScheduleEmptyState extends StatelessWidget {
  const ScheduleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size:  48,
            color: AppColors.current.textPrimary.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'No events scheduled',
            style: AppTextStyles.heading14.copyWith(
              color: AppColors.current.textPrimary.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}
