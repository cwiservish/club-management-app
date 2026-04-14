import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/enums/thread_type.dart';

/// Formats a [DateTime] into a relative timestamp string matching the Figma spec:
/// "10 min ago", "18 hrs ago", "2 days ago", "3 wks ago".
String formatRelativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hrs ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  final weeks = (diff.inDays / 7).floor();
  return '$weeks wks ago';
}

/// A single 60-px message thread row matching the Figma design:
/// - 42-px gray circle avatar on the left
/// - Thread name (16px w400) + preview text below
/// - Right-aligned relative timestamp (10px)
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.surfaceContainerHighest,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Avatar — 42px gray circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer, // #D9D9D9
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                thread.type == ThreadType.team
                    ? Icons.group_outlined
                    : Icons.person_outline,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Name + preview
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.name,
                    style: AppTextStyles.body16.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    thread.lastMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Timestamp — right-aligned, 10px
            Text(
              formatRelativeTime(thread.lastMessageTime),
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurface.withOpacity(0.55),
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
