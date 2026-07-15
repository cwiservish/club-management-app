import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../models/team_model.dart';
import '../models/player_form_config.dart';
import '../../features/messages/models/chat_member.dart';
import '../../features/messages/providers/chat_state_provider.dart';
import '../../features/messages/pages/talkjs_chat_page.dart';
import '../common_providers/selected_team_provider.dart';
import 'add_edit_player/player_form_sheet.dart';
export 'add_edit_player/player_form_sheet.dart';

// ─── AddMenuViewModel (MVVM) ──────────────────────────────────────────────────
class AddMenuViewModel {
  final Team? activeTeam;

  const AddMenuViewModel(this.activeTeam);

  /// If is_coach is true then show event, player, and chat.
  /// Else show player, chat option only (hide event).
  bool get showEvent => activeTeam == null ? true : activeTeam!.isCoach;
  bool get showPlayer => activeTeam == null ? true : activeTeam!.isCoach;
  bool get showChat => true;
}

void showAddMenu(BuildContext context, {Team? activeTeam}) {
  final viewModel = AddMenuViewModel(activeTeam);
  
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent, // As per figma, popover doesn't darken
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      final topPadding = MediaQuery.of(context).padding.top;
      final colors = AppColors.current;
      
      return Stack(
        children: [
          Positioned(
            top: 53 + topPadding + 8, // Just below the header
            right: 16,
            width: 295,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.7), // bg-white/70
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (viewModel.showEvent)
                          _MenuOption(
                            icon: '+',
                            label: 'Event',
                            onTap: () {
                              Navigator.of(context).pop();
                              // Commented out old redirection:
                              // context.push(AppRoutes.eventEdit('new'));
                              context.push(AppRoutes.newEvent);
                            },
                          ),
                        if (viewModel.showPlayer)
                          _MenuOption(
                            icon: '+',
                            label: 'Player',
                            onTap: () {
                              Navigator.of(context).pop();
                              _showNewPlayerModal(context, activeTeam: activeTeam);
                            },
                          ),
                        if (viewModel.showChat)
                          _MenuOption(
                            icon: '+',
                            label: 'Chat',
                            borderBottom: false,
                            onTap: () {
                              Navigator.of(context).pop();
                              _showNewChatModal(context);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: child,
      );
    },
  );
}

class _MenuOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool borderBottom;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.borderBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: AppColors.current.border))
              : null,
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.current.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body16.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modal Implementations ──────────────────────────────────────────────────

/*
void _showNewTeamModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NewTeamModal(),
  );
}

class _NewTeamModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Cancel', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('New Team', style: AppTextStyles.heading16.copyWith(color: colors.textPrimary)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Save', style: AppTextStyles.body15.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('TEAM NAME', 'e.g. 12 Girls ECNL RL'),
                      Divider(height: 1, color: colors.border),
                      _buildTextField('DIVISION', 'e.g. U12'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label11.copyWith(color: AppColors.current.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          TextField(
            style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.body16.copyWith(color: AppColors.current.textSecondary.withValues(alpha: 0.5)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
*/

void _showNewPlayerModal(BuildContext context, {Team? activeTeam}) {


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PlayerFormSheet(
      config: PlayerFormConfig(teamUuid: activeTeam?.uuid ?? ''),
    ),
  );


}

void _showNewChatModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NewChatModal(),
  );
}

class _NewChatModal extends ConsumerStatefulWidget {
  const _NewChatModal({super.key});

  @override
  ConsumerState<_NewChatModal> createState() => _NewChatModalState();
}

class _NewChatModalState extends ConsumerState<_NewChatModal> {
  String type = 'select';
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      if (type != 'select') {
                        setState(() {
                          type = 'select';
                          _searchController.clear();
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Cancel', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    type == 'select' ? 'New Chat' : (type == 'channel' ? 'New Channel' : 'New Direct Message'),
                    style: AppTextStyles.heading16.copyWith(color: colors.textPrimary),
                  ),
                ),
                if (type == 'channel') Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/messages/1');
                    },
                    child: Text('Create', style: AppTextStyles.body15.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (type == 'select') Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('New Channel', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('${AppRoutes.messages}/${AppRoutes.createChannel}');
                        },
                      ),
                      Divider(height: 1, color: colors.border),
                      ListTile(
                        title: Text('New Direct Message', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
                        onTap: () => setState(() => type = 'dm'),
                      ),
                    ],
                  ),
                ),
                if (type == 'channel') Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHANNEL NAME', style: AppTextStyles.label11.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'e.g. general',
                            prefixIcon: Icon(Icons.tag, size: 18, color: colors.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Channels are a great way to communicate with everyone on your team.', style: AppTextStyles.label12.copyWith(color: colors.textSecondary)),
                    ],
                  ),
                ),
                if (type == 'dm') ...[
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (val) {
                        setState(() {});
                      },
                      style: AppTextStyles.body15.copyWith(color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: AppTextStyles.body15.copyWith(color: colors.textSecondary.withValues(alpha: 0.5)),
                        prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? InkWell(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.clear,
                                  color: colors.textSecondary,
                                  size: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMemberList(colors),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(AppColors colors) {
    final selectedTeam = ref.watch(selectedTeamProvider);
    if (selectedTeam == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No active team selected',
            style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }

    final query = _searchController.text.trim();
    final isSearchingRemote = query.length >= 3;

    final membersAsync = ref.watch(chatMembersProvider(selectedTeam.uuid));
    final searchAsync = isSearchingRemote
        ? ref.watch(chatSearchDmsProvider((teamUuid: selectedTeam.uuid, query: query)))
        : null;

    if (isSearchingRemote && searchAsync != null) {
      return searchAsync.when(
        data: (searchResults) => _buildMembersListView(searchResults, colors),
        loading: () => _buildLoader(colors),
        error: (err, _) => _buildError(colors, () => ref.refresh(chatSearchDmsProvider((teamUuid: selectedTeam.uuid, query: query)))),
      );
    } else {
      return membersAsync.when(
        data: (members) {
          final filtered = members.where((m) {
            return query.isEmpty || m.name.toLowerCase().contains(query.toLowerCase());
          }).toList();
          return _buildMembersListView(filtered, colors);
        },
        loading: () => _buildLoader(colors),
        error: (err, _) => _buildError(colors, () => ref.refresh(chatMembersProvider(selectedTeam.uuid))),
      );
    }
  }

  Widget _buildMembersListView(List<ChatMember> members, AppColors colors) {
    if (members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No team members found.',
            style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: members.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: colors.border),
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              radius: 18,
              child: Text(
                _getInitials(member.name),
                style: AppTextStyles.body14.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              member.name,
              style: AppTextStyles.body16.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              Navigator.pop(context); // Close bottom sheet
              
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
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildLoader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: colors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildError(AppColors colors, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 18),
          const SizedBox(width: 8),
          Text(
            'Failed to load members.',
            style: AppTextStyles.body14.copyWith(color: colors.error),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: onRetry,
            color: colors.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
