import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/event_detail_model.dart';

class EventHeaderCard extends StatelessWidget {
  final EventDetailModel event;
  final int? scheduleGameId;

  const EventHeaderCard({super.key, required this.event, this.scheduleGameId});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Stack(
      children: [
        Container(
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
        ),
        if (scheduleGameId != null)
          Positioned(
            top: 12,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Event Game',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
