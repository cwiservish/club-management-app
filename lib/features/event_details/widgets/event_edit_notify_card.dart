import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import 'event_edit_toggle.dart';

class EventEditNotifyCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const EventEditNotifyCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width:  32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_outlined, size: 16, color: colors.actionAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notify Team',
                  style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                ),
                Text(
                  'Send push & email notifications',
                  style: AppTextStyles.label12.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          EventEditToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
