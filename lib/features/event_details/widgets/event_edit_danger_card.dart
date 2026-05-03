import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import 'event_edit_toggle.dart';

class EventEditDangerCard extends StatelessWidget {
  final bool canceled;
  final ValueChanged<bool> onCanceledChanged;
  final VoidCallback onDelete;

  const EventEditDangerCard({
    super.key,
    required this.canceled,
    required this.onCanceledChanged,
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
        children: [
          // Cancel Event toggle row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancel Event',
                        style: AppTextStyles.heading15.copyWith(color: colors.error),
                      ),
                      Text(
                        'Mark this event as canceled',
                        style: AppTextStyles.label12.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                EventEditToggle(
                  value:     canceled,
                  onChanged: onCanceledChanged,
                  isDanger:  true,
                ),
              ],
            ),
          ),
          // Delete button
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
      ),
    );
  }
}
