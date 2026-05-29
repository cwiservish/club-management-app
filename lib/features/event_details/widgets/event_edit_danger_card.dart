import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class EventEditDangerCard extends StatelessWidget {
  final VoidCallback onDelete;

  const EventEditDangerCard({
    super.key,
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
      child: InkWell(
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
    );
  }
}
