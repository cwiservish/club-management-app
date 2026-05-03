import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/thread_type.dart';
import '../../../core/models/chat_models.dart';

class ChatHeader extends StatelessWidget {
  final ChatThread thread;
  final VoidCallback onMuteTap;

  const ChatHeader({
    super.key,
    required this.thread,
    required this.onMuteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.current.headerBg,
        border: Border(
          bottom: BorderSide(color: AppColors.current.border, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              size:  16,
              color: AppColors.current.textPrimary,
            ),
            label: Text(
              'Back',
              style: AppTextStyles.body16.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.current.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  thread.name,
                  style: AppTextStyles.heading15.copyWith(
                    color: AppColors.current.textPrimary,
                  ),
                ),
                Text(
                  thread.type == ThreadType.direct
                      ? (thread.isOnline ? 'Online' : 'Offline')
                      : '19 Members',
                  style: AppTextStyles.label11.copyWith(
                    color: AppColors.current.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMuteTap,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none,
                  color: AppColors.current.textPrimary,
                  size: 24,
                ),
                Positioned(
                  bottom: -4,
                  left:   0,
                  right:  0,
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size:  14,
                      color: AppColors.current.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
