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
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.current.card, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
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
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(thread.name,
                      style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 1),
                  Text(thread.lastMessage,
                      style: AppTextStyles.body13.copyWith(
                          color: AppColors.current.textPrimary.withOpacity(0.6)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatRelativeTime(thread.lastMessageTime),
              style: AppTextStyles.label11.copyWith(
                color: AppColors.current.textPrimary.withOpacity(0.55),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
