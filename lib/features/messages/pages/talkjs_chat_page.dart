import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talkjs_flutter/talkjs_flutter.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/current_user_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../models/chat_channel.dart';
import '../providers/chat_state_provider.dart';

// ─── Args ─────────────────────────────────────────────────────────────────────

class TalkJSChatArgs {
  final String conversationId;
  final String topic;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserEmail;
  final bool isGroup;
  final String? permission;
  final DateTime? leftAt;
  final int? chatChannelId;
  final int? memberCount;

  TalkJSChatArgs({
    required this.conversationId,
    required this.topic,
    this.otherUserId,
    this.otherUserName,
    this.otherUserEmail,
    required this.isGroup,
    this.permission,
    this.leftAt,
    this.chatChannelId,
    this.memberCount,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class TalkJSChatPage extends ConsumerWidget {
  final TalkJSChatArgs args;

  const TalkJSChatPage({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAsync = ref.watch(chatTokenProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            _buildAppBar(context),
            Expanded(
              child: tokenAsync.when(
                data: (tokenResponse) {
                  return userAsync.when(
                    data: (currentUser) {
                      if (currentUser == null) {
                        return _buildErrorState('User not logged in');
                      }
                      if (args.isGroup && args.permission == 'None') {
                        return _buildLeftChannelState();
                      }
                      return _buildChatBox(tokenResponse, currentUser);
                    },
                    loading: () => _buildLoadingState(),
                    error: (err, _) =>
                        _buildErrorState('Failed to load user profile'),
                  );
                },
                loading: () => _buildLoadingState(),
                error: (err, _) =>
                    _buildErrorState('Failed to connect to chat server'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    final subtitle = args.isGroup
        ? (args.memberCount != null
            ? '${args.memberCount} Members'
            : 'Group Channel')
        : 'Direct Message';

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                // Left: < Back
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.current.textPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: AppColors.current.textPrimary,
                  ),
                  label: Text(
                    'Back',
                    style: AppTextStyles.body15.copyWith(
                      color: AppColors.current.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Center: Bold Title + Subtitle
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        args.topic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body16.copyWith(
                          color: AppColors.current.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label12.copyWith(
                          color: AppColors.current.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Bell + optional Settings
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none_outlined,
                        color: AppColors.current.textPrimary,
                        size: 22,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification settings coming soon.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    if (args.isGroup && args.permission != 'None')
                      IconButton(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: AppColors.current.textPrimary,
                          size: 22,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          context.push(
                            '${AppRoutes.messages}/${AppRoutes.editChannel}',
                            extra: ChatChannel(
                              chatChannelId: args.chatChannelId ?? 0,
                              uuid: args.conversationId,
                              clientId: 0,
                              name: args.topic,
                              channelType: 0,
                              isDefault: 0,
                              organizationId: 0,
                              teamId: 0,
                              createdById: 0,
                              createdByType: 0,
                              unreadCount: 0,
                              permission: args.permission ?? 'ReadWrite',
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox(width: 36),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.current.border),
        ],
      ),
    );
  }

  // ─── TalkJS ChatBox (handles messages + input natively) ───────────────────

  String _getJwtSub(String jwtToken) {
    try {
      final parts = jwtToken.split('.');
      if (parts.length >= 2) {
        String payload = parts[1];
        final padding = 4 - (payload.length % 4);
        if (padding > 0 && padding < 4) payload += '=' * padding;
        payload = payload.replaceAll('-', '+').replaceAll('_', '/');
        final map = json.decode(utf8.decode(base64.decode(payload)));
        return map['sub']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Error parsing JWT: $e');
    }
    return '';
  }

  Widget _buildChatBox(dynamic tokenResponse, dynamic currentUser) {
    final session = Session(
      appId: tokenResponse.appId,
      token: tokenResponse.token,
    );

    final jwtSub = _getJwtSub(tokenResponse.token);
    final talkJsUserId =
        jwtSub.isNotEmpty ? jwtSub : tokenResponse.userId as String;

    final me = session.getUser(
      id: talkJsUserId,
      name: currentUser.displayName as String,
      email: [talkJsUserId],
    );
    session.me = me;

    final Conversation conversation;
    if (args.isGroup) {
      final access = args.permission == 'Read'
          ? ParticipantAccess.read
          : ParticipantAccess.readWrite;

      conversation = session.getConversation(
        id: 'channel_${args.conversationId}',
        participants: {Participant(me, access: access)},
        subject: args.topic,
      );
    } else {
      final other = session.getUser(
        id: args.otherUserEmail!,
        name: args.otherUserName!,
        email: [args.otherUserEmail!],
      );
      conversation = session.getConversation(
        id: Talk.oneOnOneId(me.id, other.id),
        participants: {Participant(me), Participant(other)},
        subject: args.topic,
      );
    }

    // TalkJS renders the full chat UI including its own message input bar.
    // showChatHeader: false hides TalkJS's internal header (we use our own).
    return ChatBox(
      session: session,
      conversation: conversation,
      showChatHeader: false,
      theme: 'default',
    );
  }

  // ─── States ───────────────────────────────────────────────────────────────

  Widget _buildLeftChannelState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline,
                size: 64, color: AppColors.current.warning),
            const SizedBox(height: 16),
            Text(
              'No Longer a Participant',
              style: AppTextStyles.heading18.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have left or were removed from this channel, so you can no longer read or send messages here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.current.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.current.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Securing chat connection...',
            style: AppTextStyles.body14.copyWith(
              color: AppColors.current.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: AppColors.current.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load chat',
              style: AppTextStyles.heading18.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.current.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
