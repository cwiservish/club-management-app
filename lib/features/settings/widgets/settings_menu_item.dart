import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class SettingsMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SettingsMenuItem({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 37,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.current.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary)),
            Icon(Icons.chevron_right, color: AppColors.current.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
