import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/message_type.dart';
import '../../../core/enums/thread_type.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/messages_provider.dart';
import '../widgets/message_thread_row.dart';
import '../widgets/messages_header.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _chatTimestamp(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  final h    = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m    = dt.minute.toString().padLeft(2, '0');
  final sfx  = dt.hour < 12 ? 'AM' : 'PM';
  if (diff.inDays == 0)  return '$h:$m $sfx';
  if (diff.inDays == 1)  return 'Yesterday $h:$m $sfx';
  return '${dt.month}/${dt.day} $h:$m $sfx';
}

String _daySeparator(DateTime dt) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  final diff = DateTime.now().difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return '${months[dt.month - 1]} ${dt.day}';
}

// ══════════════════════════════════════════════════════════════════════════════
// Messages Screen
// ══════════════════════════════════════════════════════════════════════════════

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(messagesProvider);
    final threads = state.filtered;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const SizedBox(height: 10), // 10px white spacer — Group 835
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
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 48, color: colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text('No messages', style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          )),
          const SizedBox(height: 6),
          Text('Tap + to start a conversation',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withOpacity(0.35),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Chat Detail Screen  (internal — not moved to widgets folder — tightly coupled)
// ══════════════════════════════════════════════════════════════════════════════

class ChatDetailScreen extends ConsumerStatefulWidget {
  final ChatThread thread;
  const ChatDetailScreen({super.key, required this.thread});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _inputController  = TextEditingController();
  final _scrollController = ScrollController();
  bool _showAttachMenu    = false;
  late List<ChatMessage> _localMessages;

  // Local color shorthands scoped to the detail screen
  static const _blue   = Color(0xFF008CFF);
  static const _green  = Color(0xFF10B981);
  static const _amber  = Color(0xFFF59E0B);
  static const _purple = Color(0xFF8B5CF6);
  static const _red    = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _localMessages = List.from(ref.read(messagesProvider).messages);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _localMessages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        senderName: 'You',
        senderInitials: 'JD',
        senderColor: const Color(0xFF0EA5E9),
        text: text,
        type: MessageType.text,
        timestamp: DateTime.now(),
        isMe: true,
      ));
      _inputController.clear();
      _showAttachMenu = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,

      body: Column(
        children: [
          const AppHeader(),
          Expanded(child: _buildMessageList(colorScheme)),
          if (_showAttachMenu) _buildAttachMenu(colorScheme),
          _buildInputBar(colorScheme),
        ],
      ),
    );
  }


  Widget _buildMessageList(ColorScheme colorScheme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _localMessages.length,
      itemBuilder: (_, i) {
        final msg      = _localMessages[i];
        final prev     = i > 0 ? _localMessages[i - 1] : null;
        final showDay  = prev == null || !_sameDay(msg.timestamp, prev.timestamp);
        final showName = !msg.isMe && (prev == null || prev.senderId != msg.senderId || showDay);
        return Column(children: [
          if (showDay) _buildDaySep(msg.timestamp, colorScheme),
          _buildBubble(msg, showName, colorScheme),
        ]);
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDaySep(DateTime dt, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        Expanded(child: Divider(color: cs.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(_daySeparator(dt),
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.gray400)),
        ),
        Expanded(child: Divider(color: cs.outline)),
      ]),
    );
  }

  Widget _buildBubble(ChatMessage msg, bool showSender, ColorScheme cs) {
    final isMe = msg.isMe;
    return Padding(
      padding: EdgeInsets.only(
        top: showSender ? 10 : 2,
        bottom: msg.reactionEmoji != null ? 14 : 2,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) Padding(
            padding: const EdgeInsets.only(right: 8),
            child: showSender
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: cs.surfaceContainer,
                    child: Text(msg.senderInitials,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: cs.onSurface, fontWeight: FontWeight.w700)),
                  )
                : const SizedBox(width: 32),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showSender && !isMe) Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(msg.senderName,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.gray500, fontWeight: FontWeight.w700)),
                ),
                GestureDetector(
                  onLongPress: () => _showMessageMenu(msg, cs),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildBubbleContent(msg, isMe, cs),
                      if (msg.reactionEmoji != null)
                        Positioned(
                          bottom: -12,
                          right: isMe ? 8 : null,
                          left: isMe ? null : 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4)],
                            ),
                            child: Text(msg.reactionEmoji!,
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_chatTimestamp(msg.timestamp),
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.gray400, fontSize: 10, fontWeight: FontWeight.w400)),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        msg.isRead ? Icons.done_all : Icons.done,
                        size: 12,
                        color: msg.isRead ? _blue : AppColors.gray400,
                      ),
                    ],
                  ]),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(ChatMessage msg, bool isMe, ColorScheme cs) {
    final bubbleBg  = isMe ? _blue : cs.surface;
    final textColor = isMe ? Colors.white : cs.onSurface;
    final radius    = BorderRadius.only(
      topLeft:     const Radius.circular(18),
      topRight:    const Radius.circular(18),
      bottomLeft:  Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );

    if (msg.type == MessageType.file) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: radius,
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withOpacity(0.2) : _blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.insert_drive_file_outlined,
                color: isMe ? Colors.white : _blue, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg.fileName ?? 'File',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600, color: textColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(msg.fileSize ?? '',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isMe ? Colors.white70 : AppColors.gray400)),
            ],
          )),
          Icon(Icons.download_outlined,
              color: isMe ? Colors.white70 : AppColors.gray400, size: 18),
        ]),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleBg,
        borderRadius: radius,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2))],
      ),
      child: Text(msg.text ?? '',
          style: AppTextStyles.body14.copyWith(color: textColor, height: 1.4)),
    );
  }

  void _showMessageMenu(ChatMessage msg, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['👍', '❤️', '😂', '😮', '😢', '🙏']
                  .map((e) => GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(e, style: const TextStyle(fontSize: 26)),
                      ))
                  .toList(),
            ),
          ),
          Divider(height: 1, color: cs.outline),
          _menuItem(Icons.reply_outlined,       'Reply',   cs.onSurface),
          _menuItem(Icons.content_copy_outlined, 'Copy',   cs.onSurface),
          if (msg.isMe) _menuItem(Icons.delete_outline, 'Delete', _red),
        ]),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label,
          style: AppTextStyles.body14.copyWith(
              fontWeight: FontWeight.w500, color: color)),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildAttachMenu(ColorScheme cs) {
    final actions = [
      (Icons.image_outlined,       'Photo',    const Color(0xFF0EA5E9)),
      (Icons.camera_alt_outlined,  'Camera',   _green),
      (Icons.attach_file_outlined, 'File',     _purple),
      (Icons.location_on_outlined, 'Location', _amber),
      (Icons.contact_page_outlined,'Contact',  _blue),
    ];
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) => GestureDetector(
          onTap: () => setState(() => _showAttachMenu = false),
          child: Column(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: a.$3.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(a.$1, color: a.$3, size: 22),
            ),
            const SizedBox(height: 6),
            Text(a.$2,
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.gray500)),
          ]),
        )).toList(),
      ),
    );
  }

  Widget _buildInputBar(ColorScheme cs) {
    return Container(
      color: cs.surface,
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 10
            : MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showAttachMenu = !_showAttachMenu),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38, height: 38,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: _showAttachMenu
                    ? _blue.withOpacity(0.1)
                    : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showAttachMenu ? Icons.close : Icons.add,
                color: _showAttachMenu ? _blue : AppColors.gray500,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.body14.copyWith(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Message…',
                  hintStyle: AppTextStyles.body14.copyWith(
                      color: cs.onSurface.withOpacity(0.4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder(
            valueListenable: _inputController,
            builder: (_, value, __) {
              final hasText = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: hasText ? _sendMessage : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38, height: 38,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: hasText ? _blue : cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasText ? Icons.send : Icons.mic_outlined,
                    color: hasText ? Colors.white : AppColors.gray500,
                    size: 18,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showThreadInfo() {
    final thread = widget.thread;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (_, ctrl) {
          final cs = Theme.of(context).colorScheme;
          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: cs.surfaceContainer,
                    child: Text(thread.avatarInitials,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: cs.onSurface, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(thread.name,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: cs.onSurface)),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    thread.type == ThreadType.direct
                        ? (thread.isOnline ? '● Online' : 'Offline')
                        : 'Group · 8 members',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: thread.isOnline && thread.type == ThreadType.direct
                          ? _green
                          : AppColors.gray400,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _infoAction(Icons.volume_off_outlined, 'Mute',     color: _blue),
                    const SizedBox(width: 24),
                    _infoAction(Icons.search,              'Search',   color: _blue),
                    const SizedBox(width: 24),
                    _infoAction(Icons.push_pin_outlined,   'Pin',      color: _blue),
                    const SizedBox(width: 24),
                    _infoAction(Icons.exit_to_app,         'Leave',    color: _red),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoAction(IconData icon, String label, {required Color color}) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: AppTextStyles.labelSmall.copyWith(
                color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  void _showMoreMenu() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _menuItem(Icons.search,                    'Search in Conversation',  cs.onSurface),
          _menuItem(Icons.notifications_outlined,    'Mute Notifications',      cs.onSurface),
          _menuItem(Icons.push_pin_outlined,         'Pin Conversation',        cs.onSurface),
          _menuItem(Icons.delete_outline,            'Delete Conversation',     _red),
        ]),
      ),
    );
  }
}
