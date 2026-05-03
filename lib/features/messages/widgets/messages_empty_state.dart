import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class MessagesEmptyState extends StatelessWidget {
  const MessagesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size:  48,
            color: AppColors.current.textPrimary.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No messages',
            style: AppTextStyles.heading15.copyWith(
              color: AppColors.current.textPrimary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to start a conversation',
            style: AppTextStyles.body13.copyWith(
              color: AppColors.current.textPrimary.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}
