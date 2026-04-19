import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/event_detail_model.dart';

class EventHeaderCard extends StatelessWidget {
  final EventDetailModel event;

  const EventHeaderCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 24,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            event.name,
            style: AppTextStyles.heading22.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            event.date,
            style: AppTextStyles.body16.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            event.timeRange,
            style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
