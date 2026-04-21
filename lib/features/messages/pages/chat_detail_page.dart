import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/enums/message_type.dart';
import '../../../core/enums/thread_type.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/messages_provider.dart';

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
// Chat Detail Screen
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
  bool _hasText           = false;
  late List<ChatMessage> _localMessages;

  @override
  void initState() {
    super.initState();
    _localMessages = List.from(ref.read(messagesProvider).messages);
    _inputController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _inputController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _inputController.removeListener(_onTextChanged);
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
        senderColor: AppColors.current.sky,
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
    ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: AppColors.current.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            _buildChatHeader(),
            Expanded(child: _buildMessageList()),
            if (_showAttachMenu) _buildAttachMenu(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
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
            icon: Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.current.textPrimary),
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
                  widget.thread.name,
                  style: AppTextStyles.heading15.copyWith(color: AppColors.current.textPrimary),
                ),
                Text(
                  widget.thread.type == ThreadType.direct ? (widget.thread.isOnline ? 'Online' : 'Offline') : '19 Members',
                  style: AppTextStyles.label11.copyWith(
                    color: AppColors.current.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showMuteMenu,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none, color: AppColors.current.textPrimary, size: 24),
                Positioned(
                  bottom: -4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.current.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _localMessages.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _buildPreviousMessagesButton();
        
        final msg      = _localMessages[i - 1];
        final prev     = i > 1 ? _localMessages[i - 2] : null;
        final showDay  = prev == null || !_sameDay(msg.timestamp, prev.timestamp);
        final showName = !msg.isMe && (prev == null || prev.senderId != msg.senderId || showDay);
        
        return Column(children: [
          if (showDay) _buildDaySep(msg.timestamp),
          _buildBubble(msg, showName),
        ]);
      },
    );
  }

  Widget _buildPreviousMessagesButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.current.card.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'PREVIOUS MESSAGES',
            style: AppTextStyles.buttonLabel.copyWith(
              fontSize: 11,
              color: AppColors.current.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDaySep(DateTime dt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        Expanded(child: Divider(color: AppColors.current.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(_daySeparator(dt),
              style: AppTextStyles.label11.copyWith(color: AppColors.current.gray400)),
        ),
        Expanded(child: Divider(color: AppColors.current.border)),
      ]),
    );
  }

  Widget _buildBubble(ChatMessage msg, bool showSender) {
    final isMe = msg.isMe;
    return Padding(
      padding: EdgeInsets.only(
        top: showSender ? 12 : 4,
        bottom: 4,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) Padding(
            padding: const EdgeInsets.only(right: 12, top: 20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.current.card,
              child: Text(msg.senderInitials,
                  style: AppTextStyles.label12.copyWith(
                    color: AppColors.current.textPrimary,
                    fontWeight: FontWeight.w700)),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(msg.senderName,
                        style: AppTextStyles.heading14.copyWith(
                            color: AppColors.current.textPrimary,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(_chatTimestamp(msg.timestamp),
                        style: AppTextStyles.label12.copyWith(
                            color: AppColors.current.textSecondary,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
                if (isMe) Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_chatTimestamp(msg.timestamp),
                        style: AppTextStyles.label12.copyWith(
                            color: AppColors.current.textSecondary,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(width: 8),
                    Text('You',
                        style: AppTextStyles.heading14.copyWith(
                            color: AppColors.current.textPrimary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 4),
                _buildBubbleContent(msg, isMe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(ChatMessage msg, bool isMe) {
    final radius = BorderRadius.circular(16);

    if (msg.type == MessageType.file) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.current.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: AppColors.current.card,
            child: Icon(Icons.image_outlined, size: 48, color: AppColors.current.gray400),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.current.primary : AppColors.current.surface,
        borderRadius: radius,
        border: isMe ? null : Border.all(
          color: AppColors.current.border.withOpacity(1.0),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        msg.text ?? '',
        style: AppTextStyles.body15.copyWith(
          color: isMe ? Colors.white : AppColors.current.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAttachMenu() {
    final actions = [
      (Icons.image_outlined,       'Photo',    const Color(0xFF0EA5E9)),
      (Icons.camera_alt_outlined,  'Camera',   AppColors.current.emerald),
      (Icons.attach_file,          'File',     AppColors.current.purple),
      (Icons.location_on_outlined, 'Location', AppColors.current.warning),
      (Icons.contact_page_outlined,'Contact',  AppColors.current.primary),
    ];
    return Container(
      color: AppColors.current.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          Widget icon = Icon(a.$1, color: a.$3, size: 22);
          if (a.$1 == Icons.attach_file) {
            icon = Transform.rotate(
              angle: 0.6,
              child: Transform.scale(scaleX: -1, child: icon),
            );
          }
          return GestureDetector(
            onTap: () => setState(() => _showAttachMenu = false),
            child: Column(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: a.$3.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: icon,
              ),
              const SizedBox(height: 6),
              Text(a.$2,
                  style: AppTextStyles.label11.copyWith(
                      color: AppColors.current.textSecondary)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 8, right: 16, top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 8
            : MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.current.headerBg,
        border: Border(top: BorderSide(color: AppColors.current.border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.current.card,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => setState(() => _showAttachMenu = !_showAttachMenu),
              icon: Transform.rotate(
                angle: 0.6,
                child: Transform.scale(
                  scaleX: -1,
                  child: Icon(Icons.attach_file, color: AppColors.current.textSecondary, size: 22),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.current.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _hasText ? AppColors.current.primary : Colors.transparent,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: AppTextStyles.body15.copyWith(color: AppColors.current.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.body15.copyWith(
                          color: AppColors.current.textSecondary.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.camera_alt_outlined, color: AppColors.current.textSecondary, size: 22),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasText ? AppColors.current.primary : AppColors.current.card,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: _hasText ? 0 : -0.6, // More counter-clockwise to point vertically more
                  child: Icon(
                    _hasText ? Icons.send : Icons.send_outlined,
                    color: _hasText ? Colors.white : AppColors.current.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMuteMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Mute conversation for',
                  style: AppTextStyles.body14.copyWith(
                    color: AppColors.current.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.current.border),
              _muteItem('2 hours'),
              Divider(height: 1, color: AppColors.current.border),
              _muteItem('4 hours'),
              Divider(height: 1, color: AppColors.current.border),
              _muteItem('Until Tomorrow'),
              Divider(height: 1, color: AppColors.current.border),
              _muteItem('Until I Unmute'),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _muteItem(String label) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body16.copyWith(
            color: AppColors.current.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
