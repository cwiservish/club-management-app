import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talkjs_flutter/talkjs_flutter.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/current_user_provider.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../models/chat_channel.dart';
import '../models/chat_member.dart';
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
  final bool canEdit;

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
    this.canEdit = true,
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
    ref.watch(themeModeProvider);
    final tokenAsync = ref.watch(chatTokenProvider);
    final userAsync = ref.watch(currentUserProvider);
    final session = ref.watch(talkJsSessionProvider);
    final selectedTeam = ref.watch(selectedTeamProvider);
    final channelsAsync = selectedTeam != null ? ref.watch(chatChannelsProvider(selectedTeam.uuid)) : null;
    ChatChannel? activeChannel;
    if (channelsAsync != null && channelsAsync.hasValue && args.chatChannelId != null) {
      for (final c in channelsAsync.value!) {
        if (c.chatChannelId == args.chatChannelId) {
          activeChannel = c;
          break;
        }
      }
    }

    String displayName = args.topic;
    if (activeChannel != null && activeChannel!.channelType == 6 && activeChannel!.teamId != 0) {
      final parts = <String>[];
      if (activeChannel!.teamName != null && activeChannel!.teamName!.isNotEmpty) {
        parts.add(activeChannel!.teamName!);
      }
      if (activeChannel!.teamDivision != null && activeChannel!.teamDivision!.isNotEmpty) {
        parts.add(activeChannel!.teamDivision!);
      }
      if (activeChannel!.teamLevel != null && activeChannel!.teamLevel!.isNotEmpty) {
        parts.add(activeChannel!.teamLevel!);
      }
      if (parts.isNotEmpty) {
        displayName = parts.join(' ');
      }
    }

    final isThread = args.conversationId.startsWith('replyto_');
    final isChannelThread = isThread && args.chatChannelId != null;

    final AsyncValue<List<ChatMember>>? membersAsync = isChannelThread && selectedTeam != null
        ? ref.watch(chatChannelMembersProvider((
            teamUuid: selectedTeam.uuid,
            chatChannelId: args.chatChannelId!,
          )))
        : null;

    return Scaffold(
      backgroundColor: AppColors.current.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            _buildAppBar(context, displayName),
            Expanded(
              child: session != null
                  ? (args.isGroup && args.permission == 'None'
                      ? _buildLeftChannelState()
                      : (isChannelThread && membersAsync != null && membersAsync.isLoading
                          ? _buildLoadingState()
                          : isChannelThread && membersAsync != null && membersAsync.hasError
                              ? _buildErrorState('Failed to load thread participants')
                              : _buildChatBox(context, session, membersAsync, displayName)))
                  : tokenAsync.when(
                      data: (tokenResponse) {
                        return userAsync.when(
                          data: (currentUser) {
                            if (currentUser == null) {
                              return _buildErrorState('User not logged in');
                            }
                            if (args.isGroup && args.permission == 'None') {
                              return _buildLeftChannelState();
                            }
                            return _buildLoadingState();
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

  Widget _buildAppBar(BuildContext context, String displayName) {
    final String subtitle;
    if (args.conversationId.startsWith('replyto_')) {
      subtitle = 'Thread';
    } else {
      subtitle = args.isGroup
          ? (args.memberCount != null
              ? '${args.memberCount} Members'
              : 'Group Channel')
          : 'Direct Message';
    }

    return Container(
      width: double.infinity,
      color: AppColors.current.headerBg,
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
                        displayName,
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
                    if (args.isGroup && args.permission != 'None' && !args.conversationId.startsWith('replyto_'))
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
                              canEdit: args.canEdit,
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox(width: 36),
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

  void _handleThreadReply(BuildContext context, MessageActionEvent event, Conversation parentConversation) {
    context.push(
      '${AppRoutes.messages}/${AppRoutes.messagesChatDetail}',
      extra: TalkJSChatArgs(
        conversationId: 'replyto_${parentConversation.id}_${event.message.id}',
        topic: parentConversation.subject ?? 'Thread',
        isGroup: true,
        permission: args.permission,
        chatChannelId: args.chatChannelId,
        otherUserId: args.otherUserId,
        otherUserName: args.otherUserName,
        otherUserEmail: args.otherUserEmail,
      ),
    );
  }

  Widget _buildChatBox(
    BuildContext context,
    Session session,
    AsyncValue<List<ChatMember>>? membersAsync,
    String displayName,
  ) {
    final me = session.me;

    final Conversation conversation;
    if (args.conversationId.startsWith('replyto_')) {
      final Set<Participant> participants = {Participant(me)};
      if (args.chatChannelId != null && membersAsync != null && membersAsync.hasValue) {
        final members = membersAsync.value ?? [];
        for (final m in members) {
          if (m.email.isNotEmpty) {
            final u = session.getUser(
              id: m.email,
              name: m.name,
              email: [m.email],
            );
            participants.add(Participant(u));
          }
        }
      } else if (args.otherUserEmail != null) {
        final other = session.getUser(
          id: args.otherUserEmail!,
          name: args.otherUserName!,
          email: [args.otherUserEmail!],
        );
        participants.add(Participant(other));
      }

      conversation = session.getConversation(
        id: args.conversationId,
        participants: participants,
        subject: displayName,
      );
    } else if (args.isGroup) {
      final access = args.permission == 'Read'
          ? ParticipantAccess.read
          : ParticipantAccess.readWrite;

      conversation = session.getConversation(
        id: 'channel_${args.conversationId}',
        participants: {Participant(me, access: access)},
        subject: displayName,
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
        subject: displayName,
      );
    }

    // TalkJS renders the full chat UI including its own message input bar.
    // showChatHeader: false hides TalkJS's internal header (we use our own).
    return ChatBox(
      session: session,
      conversation: conversation,
      showChatHeader: false,
      theme: AppColors.current.isDark ? 'default_dark' : 'default',
      onCustomMessageAction: {
        'reply': (event) => _handleThreadReply(context, event, conversation),
        'reply_in_thread': (event) => _handleThreadReply(context, event, conversation),
        'replyInThread': (event) => _handleThreadReply(context, event, conversation),
        'view_thread': (event) => _handleThreadReply(context, event, conversation),
        'viewThread': (event) => _handleThreadReply(context, event, conversation),
      },
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
