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
import 'new_chat_sheet.dart';
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
      floatingActionButton: selectedTeam != null
          ? FloatingActionButton(
              onPressed: () => _showNewChatSheet(context),
              backgroundColor: AppColors.current.primary,
              child: const Icon(Icons.message, color: Colors.white),
            )
          : null,
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
        onTap: () {
          context.push(
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
                    Text(
                      '# ${channel.name}',
                      style: AppTextStyles.body15.copyWith(
                        color: AppColors.current.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      channel.lastMessageText ?? 'No messages yet...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label12.copyWith(
                        color: AppColors.current.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
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
    final membersAsync = ref.watch(chatMembersProvider(teamUuid));
    final dmSearch = _dmSearchController.text.trim().toLowerCase();
    final count = membersAsync.asData?.value.where((m) {
      final matchesGlobal = searchQuery.isEmpty || m.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesInline = dmSearch.isEmpty || m.name.toLowerCase().contains(dmSearch);
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
          membersAsync.when(
            data: (members) {
              final dmSearch = _dmSearchController.text.trim().toLowerCase();
              final filtered = members.where((m) {
                // Filters by global query or DM-specific inline search query
                final matchesGlobal = searchQuery.isEmpty || m.name.toLowerCase().contains(searchQuery.toLowerCase());
                final matchesInline = dmSearch.isEmpty || m.name.toLowerCase().contains(dmSearch);
                return matchesGlobal && matchesInline;
              }).toList();

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(
                    dmSearch.isEmpty ? 'No members found.' : 'No members match search.',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context, ChatMember member) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          context.push(
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
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: AppTextStyles.body16.copyWith(
                  color: AppColors.current.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                member.lastMessageText ?? 'No messages yet...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label12.copyWith(
                  color: AppColors.current.textSecondary.withOpacity(0.7),
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

  void _showNewChatSheet(BuildContext context) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => const NewChatSheet(),
    );

    if (result == 'focus_dms') {
      setState(() {
        _isDmsExpanded = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dmSearchFocusNode.requestFocus();
      });
    }
  }
}

