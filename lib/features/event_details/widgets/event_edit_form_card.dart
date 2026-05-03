import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class EventEditFormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const EventEditFormCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      decoration: BoxDecoration(
        color:        colors.background,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Section header
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:  colors.card.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: colors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color:      colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
