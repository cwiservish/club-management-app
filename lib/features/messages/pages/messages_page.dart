import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/messages_provider.dart';
import '../widgets/message_thread_row.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Messages Screen
// ══════════════════════════════════════════════════════════════════════════════

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final state   = ref.watch(messagesProvider);
    final threads = state.filtered;

    return Scaffold(
      backgroundColor: AppColors.current.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            _buildMessagesTitleBar(),
            Expanded(
              child: threads.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: threads.length,
                      itemBuilder: (_, i) => MessageThreadRow(
                        thread: threads[i],
                        onTap: () => context.push(
                          '/messages/${AppRoutes.messagesChatDetail}',
                          extra: threads[i],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTitleBar() {
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 48, color: AppColors.current.textPrimary.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text('No messages', style: AppTextStyles.heading15.copyWith(
            color: AppColors.current.textPrimary.withOpacity(0.5),
          )),
          const SizedBox(height: 6),
          Text('Tap + to start a conversation',
              style: AppTextStyles.body13.copyWith(
                color: AppColors.current.textPrimary.withOpacity(0.35),
              )),
        ],
      ),
    );
  }
}
