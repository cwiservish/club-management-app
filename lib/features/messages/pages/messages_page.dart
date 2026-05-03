import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/messages_provider.dart';
import '../widgets/message_thread_row.dart';
import '../widgets/messages_empty_state.dart';
import '../widgets/messages_title_bar.dart';

// ─── Messages Screen ──────────────────────────────────────────────────────────

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final threads = ref.watch(messagesProvider).filtered;

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            const MessagesTitleBar(),
            Expanded(
              child: threads.isEmpty
                  ? const MessagesEmptyState()
                  : ListView.builder(
                      padding:   EdgeInsets.zero,
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
}
