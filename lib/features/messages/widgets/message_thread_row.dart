import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/enums/thread_type.dart';

String formatRelativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hrs ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  final weeks = (diff.inDays / 7).floor();
  return '$weeks wks ago';
}

class MessageThreadRow extends StatelessWidget {
  final ChatThread thread;
  final VoidCallback onTap;

  const MessageThreadRow({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.current.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.current.card,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                thread.type == ThreadType.team
                    ? Icons.group_outlined
                    : Icons.person_outline,
                color: AppColors.current.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          thread.name,
                          style: AppTextStyles.body16.copyWith(
                            color: AppColors.current.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatRelativeTime(thread.lastMessageTime),
                        style: AppTextStyles.label12.copyWith(
                          color: AppColors.current.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.lastMessage,
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.current.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.current.border,
            ),
          ],
        ),
      ),
    );
  }
}
