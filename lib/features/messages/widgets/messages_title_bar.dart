import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class MessagesTitleBar extends StatelessWidget {
  const MessagesTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.current.border, width: 1),
        ),
      ),
      child: Text(
        'Messages',
        style: AppTextStyles.heading20.copyWith(
          color: AppColors.current.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
