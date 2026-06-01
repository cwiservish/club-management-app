import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import 'event_edit_toggle.dart';

class EventEditDangerCard extends StatelessWidget {
  final bool isEdit;
  final bool isCancelled;
  final ValueChanged<bool> onCancelledChanged;
  final VoidCallback onDelete;

  const EventEditDangerCard({
    super.key,
    required this.isEdit,
    required this.isCancelled,
    required this.onCancelledChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      decoration: BoxDecoration(
        color:        colors.background,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: colors.error.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cancel Event Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancel Event',
                        style: AppTextStyles.heading15.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mark this event as canceled',
                        style: AppTextStyles.body14.copyWith(
                          color: colors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                EventEditToggle(
                  value: isCancelled,
                  onChanged: onCancelledChanged,
                  isDanger: true,
                ),
              ],
            ),
          ),
          if (isEdit) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: colors.error.withValues(alpha: 0.2),
            ),
            // Delete Event Section
            InkWell(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: colors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Delete Event Permanently',
                      style: AppTextStyles.heading15.copyWith(color: colors.error),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
