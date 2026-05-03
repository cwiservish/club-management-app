import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/message_type.dart';
import '../../../core/models/chat_models.dart';

// ─── Formatting helpers ───────────────────────────────────────────────────────

String _chatTimestamp(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  final h    = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m    = dt.minute.toString().padLeft(2, '0');
  final sfx  = dt.hour < 12 ? 'AM' : 'PM';
  if (diff.inDays == 0) return '$h:$m $sfx';
  if (diff.inDays == 1) return 'Yesterday $h:$m $sfx';
  return '${dt.month}/${dt.day} $h:$m $sfx';
}

String _daySeparator(DateTime dt) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  final diff = DateTime.now().difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return '${months[dt.month - 1]} ${dt.day}';
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ─── Chat Message List ────────────────────────────────────────────────────────

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return const _PreviousMessagesButton();

        final msg     = messages[i - 1];
        final prev    = i > 1 ? messages[i - 2] : null;
        final showDay = prev == null || !_sameDay(msg.timestamp, prev.timestamp);
        final showName = !msg.isMe &&
            (prev == null || prev.senderId != msg.senderId || showDay);

        return Column(children: [
          if (showDay) _DaySeparatorRow(dt: msg.timestamp),
          _MessageBubble(msg: msg, showSender: showName),
        ]);
      },
    );
  }
}

// ─── Previous messages button ─────────────────────────────────────────────────

class _PreviousMessagesButton extends StatelessWidget {
  const _PreviousMessagesButton();

  @override
  Widget build(BuildContext context) {
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
}

// ─── Day separator row ────────────────────────────────────────────────────────

class _DaySeparatorRow extends StatelessWidget {
  final DateTime dt;
  const _DaySeparatorRow({required this.dt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        Expanded(child: Divider(color: AppColors.current.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _daySeparator(dt),
            style: AppTextStyles.label11.copyWith(
              color: AppColors.current.gray400,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.current.border)),
      ]),
    );
  }
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool showSender;
  const _MessageBubble({required this.msg, required this.showSender});

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    return Padding(
      padding: EdgeInsets.only(top: showSender ? 12 : 4, bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 20),
              child: Container(
                width:  36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.current.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.current.border, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  msg.senderInitials,
                  style: AppTextStyles.label12.copyWith(
                    color: AppColors.current.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.senderName,
                        style: AppTextStyles.heading14.copyWith(
                          color: AppColors.current.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _chatTimestamp(msg.timestamp),
                        style: AppTextStyles.label12.copyWith(
                          color: AppColors.current.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                if (isMe)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _chatTimestamp(msg.timestamp),
                        style: AppTextStyles.label12.copyWith(
                          color: AppColors.current.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'You',
                        style: AppTextStyles.heading14.copyWith(
                          color: AppColors.current.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                _BubbleContent(msg: msg, isMe: isMe),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bubble content ───────────────────────────────────────────────────────────

class _BubbleContent extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;
  const _BubbleContent({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
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
            child: Icon(
              Icons.image_outlined,
              size:  48,
              color: AppColors.current.gray400,
            ),
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
        border: isMe
            ? null
            : Border.all(
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
}
