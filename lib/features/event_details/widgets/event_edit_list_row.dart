import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class EventEditListRow extends StatelessWidget {
  final String label;
  final String value;
  final bool borderBottom;
  final VoidCallback? onTap;

  const EventEditListRow({
    super.key,
    required this.label,
    required this.value,
    this.borderBottom = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
              ),
            ),
            Text(
              value,
              style:    AppTextStyles.body16.copyWith(color: colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
