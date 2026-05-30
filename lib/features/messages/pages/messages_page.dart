import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../models/chat_channel.dart';
import '../models/chat_member.dart';
import '../providers/chat_state_provider.dart';
import 'talkjs_chat_page.dart'; // for TalkJSChatArgs

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  bool _isChannelsExpanded = true;
  bool _isDmsExpanded = true;
  final _dmSearchController = TextEditingController();
  final _dmSearchFocusNode = FocusNode();

  @override
  void dispose() {
    _dmSearchController.dispose();
    _dmSearchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final selectedTeam = ref.watch(selectedTeamProvider);
    final searchQuery = ref.watch(chatSearchQueryProvider);
    ref.watch(talkJsSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.current.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            _buildTitleBar(),
            if (selectedTeam == null)
              Expanded(child: _buildNoTeamState())
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(chatChannelsProvider(selectedTeam.uuid));
                    ref.invalidate(chatMembersProvider(selectedTeam.uuid));
                  },
                  color: AppColors.current.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChannelsSection(selectedTeam.uuid, searchQuery),
                          const SizedBox(height: 24),
                          _buildDmsSection(selectedTeam.uuid, searchQuery),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
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

  Widget _buildNoTeamState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_work_outlined, size: 64, color: AppColors.current.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Team Selected',
              style: AppTextStyles.heading18.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please select or switch to a team from the header above to load active channels and members.',
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

  // ─── CHANNELS SECTION ──────────────────────────────────────────────────────

  Widget _buildChannelsSection(String teamUuid, String searchQuery) {
    final channelsAsync = ref.watch(chatChannelsProvider(teamUuid));
    final count = channelsAsync.asData?.value.where((c) {
      final query = searchQuery.toLowerCase();
      return query.isEmpty || c.name.toLowerCase().contains(query);
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isChannelsExpanded = !_isChannelsExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.transparent,
            child: Row(
              children: [
                Icon(
                  _isChannelsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.current.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'CHANNELS',
                  style: AppTextStyles.heading13.copyWith(
                    color: AppColors.current.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                if (count != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.current.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.current.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.label12.copyWith(
                        color: AppColors.current.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isChannelsExpanded) ...[
          channelsAsync.when(
            data: (channels) {
              final filtered = channels.where((c) {
                final query = searchQuery.toLowerCase();
                return query.isEmpty || c.name.toLowerCase().contains(query);
              }).toList();

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(
                    searchQuery.isEmpty ? 'No channels active.' : 'No channels match search.',
                    style: AppTextStyles.body13.copyWith(color: AppColors.current.textSecondary),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final channel = filtered[index];
                  // Make first channel appear highlighted/active just like the mock team-1
                  final isActive = index == 0;
                  return _buildChannelItem(context, channel, isActive);
                },
              );
            },
            loading: () => _buildSectionLoader(),
            error: (err, _) => _buildSectionError(() => ref.refresh(chatChannelsProvider(teamUuid))),
          ),
        ],
      ],
    );
  }

  Widget _buildChannelItem(BuildContext context, ChatChannel channel, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.current.card : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () async {
          await context.push(
            '${AppRoutes.messages}/${AppRoutes.messagesChatDetail}',
            extra: TalkJSChatArgs(
              conversationId: channel.uuid,
              topic: channel.name,
              isGroup: true,
              chatChannelId: channel.chatChannelId,
              permission: channel.permission,
              leftAt: channel.leftAt,
              memberCount: channel.memberCount,
            ),
          );
          final activeTeam = ref.read(selectedTeamProvider);
          if (activeTeam != null) {
            ref.invalidate(chatChannelsProvider(activeTeam.uuid));
            ref.invalidate(chatMembersProvider(activeTeam.uuid));
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (channel.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.current.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            '# ${channel.name}',
                            style: AppTextStyles.body15.copyWith(
                              color: AppColors.current.textPrimary,
                              fontWeight: channel.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      channel.lastMessageText ?? 'No messages yet...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label12.copyWith(
                        color: channel.unreadCount > 0
                            ? AppColors.current.textPrimary
                            : AppColors.current.textSecondary.withOpacity(0.7),
                        fontWeight: channel.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (channel.unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.current.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${channel.unreadCount}',
                    style: AppTextStyles.label12.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isActive)
                Icon(
                  Icons.people_alt,
                  color: AppColors.current.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DIRECT MESSAGES SECTION ───────────────────────────────────────────────

  Widget _buildDmsSection(String teamUuid, String searchQuery) {
    final dmQuery = _dmSearchController.text.trim();
    final isSearchingRemote = dmQuery.length >= 3;

    final membersAsync = ref.watch(chatMembersProvider(teamUuid));
    final searchAsync = isSearchingRemote
        ? ref.watch(chatSearchDmsProvider((teamUuid: teamUuid, query: dmQuery)))
        : null;

    final count = isSearchingRemote
        ? searchAsync?.asData?.value.length
        : membersAsync.asData?.value.where((m) {
            final matchesGlobal = searchQuery.isEmpty || m.name.toLowerCase().contains(searchQuery.toLowerCase());
            final matchesInline = dmQuery.isEmpty || m.name.toLowerCase().contains(dmQuery.toLowerCase());
            return matchesGlobal && matchesInline;
          }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDmsExpanded = !_isDmsExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.transparent,
            child: Row(
              children: [
                Icon(
                  _isDmsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.current.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'DIRECT MESSAGES',
                  style: AppTextStyles.heading13.copyWith(
                    color: AppColors.current.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                if (count != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.current.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.current.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.label12.copyWith(
                        color: AppColors.current.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isDmsExpanded) ...[
          _buildDmSearchBar(),
          const SizedBox(height: 8),
          if (isSearchingRemote && searchAsync != null)
            searchAsync.when(
              data: (searchResults) {
                if (searchResults.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      'No members found matching "$dmQuery".',
                      style: AppTextStyles.body13.copyWith(color: AppColors.current.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final member = searchResults[index];
                    return _buildMemberItem(context, member);
                  },
                );
              },
              loading: () => _buildSectionLoader(),
              error: (err, _) => _buildSectionError(() => ref.refresh(chatSearchDmsProvider((teamUuid: teamUuid, query: dmQuery)))),
            )
          else
            membersAsync.when(
              data: (members) {
                final filtered = members.where((m) {
                  final matchesGlobal = searchQuery.isEmpty || m.name.toLowerCase().contains(searchQuery.toLowerCase());
                  final matchesInline = dmQuery.isEmpty || m.name.toLowerCase().contains(dmQuery.toLowerCase());
                  return matchesGlobal && matchesInline;
                }).toList();

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      dmQuery.isEmpty ? 'No members found.' : 'No members match search.',
                      style: AppTextStyles.body13.copyWith(color: AppColors.current.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final member = filtered[index];
                    return _buildMemberItem(context, member);
                  },
                );
              },
              loading: () => _buildSectionLoader(),
              error: (err, _) => _buildSectionError(() => ref.refresh(chatMembersProvider(teamUuid))),
            ),
        ],
      ],
    );
  }

  Widget _buildDmSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _dmSearchController,
        focusNode: _dmSearchFocusNode,
        onChanged: (val) {
          setState(() {}); // refresh inline filtered DM lists
        },
        style: AppTextStyles.body14.copyWith(color: AppColors.current.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary.withOpacity(0.5)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.only(left: 12, right: 8, top: 10, bottom: 10),
          suffixIcon: _dmSearchController.text.isNotEmpty
              ? InkWell(
                  onTap: () {
                    _dmSearchController.clear();
                    setState(() {});
                  },
                  child: Icon(
                    Icons.clear,
                    color: AppColors.current.textSecondary,
                    size: 18,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context, ChatMember member) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          await context.push(
            '${AppRoutes.messages}/${AppRoutes.messagesChatDetail}',
            extra: TalkJSChatArgs(
              conversationId: member.uuid,
              topic: member.name,
              isGroup: false,
              otherUserId: member.uuid,
              otherUserName: member.name,
              otherUserEmail: member.email,
            ),
          );
          final activeTeam = ref.read(selectedTeamProvider);
          if (activeTeam != null) {
            ref.invalidate(chatChannelsProvider(activeTeam.uuid));
            ref.invalidate(chatMembersProvider(activeTeam.uuid));
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (member.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.current.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            member.name,
                            style: AppTextStyles.body16.copyWith(
                              color: AppColors.current.textPrimary,
                              fontWeight: member.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.lastMessageText ?? 'No messages yet...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label12.copyWith(
                        color: member.unreadCount > 0
                            ? AppColors.current.textPrimary
                            : AppColors.current.textSecondary.withOpacity(0.7),
                        fontWeight: member.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (member.unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.current.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${member.unreadCount}',
                    style: AppTextStyles.label12.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  Widget _buildSectionLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.current.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionError(VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.current.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load updates.',
              style: AppTextStyles.body13.copyWith(color: AppColors.current.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: onRetry,
            color: AppColors.current.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

}

