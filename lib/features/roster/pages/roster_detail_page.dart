import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../models/roster_detail_contact.dart';
import '../models/roster_member.dart';
import '../models/player_profile_models.dart';
import '../../../core/models/player_form_config.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/shared_widgets/add_menu_dialog.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/roster_detail_provider.dart';
import '../providers/player_profile_provider.dart';
import '../widgets/roster_detail_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Roster Detail Page (Player Profile)
// ══════════════════════════════════════════════════════════════════════════════

class RosterDetailPage extends ConsumerStatefulWidget {
  final String? memberId;
  const RosterDetailPage({super.key, this.memberId});

  @override
  ConsumerState<RosterDetailPage> createState() => _RosterDetailPageState();
}

class _RosterDetailPageState extends ConsumerState<RosterDetailPage> {
  String? _memberId;

  @override
  void initState() {
    super.initState();
    if (widget.memberId?.isNotEmpty == true) _memberId = widget.memberId;
  }

  @override
  void didUpdateWidget(RosterDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.memberId?.isNotEmpty == true) _memberId = widget.memberId;
  }

  @override
  Widget build(BuildContext context) {
    final memberId = _memberId;
    if (memberId == null) return const SizedBox.shrink();

    ref.watch(themeModeProvider);

    // Fetch the local fallback roster member immediately to populate name/initials
    final member = ref.watch(rosterDetailProvider(memberId));
    if (member == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Watch the dynamic player profile API state
    final profileState = ref.watch(playerProfileProvider(memberId));
    final profile = profileState.profile?.data.player;
    final parents = profileState.profile?.data.parents ?? [];

    // Dynamically build contact list from API parents list, falling back to local mock data
    final List<RosterDetailContact> contacts = [];
    if (profileState.profile != null) {
      for (final p in parents) {
        final initials = p.name.isNotEmpty
            ? p.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
            : 'P';
        final clippedInitials = initials.substring(0, initials.length.clamp(0, 2));

        contacts.add(RosterDetailContact(
          name: p.name,
          initials: clippedInitials,
          relation: 'Parent',
          email: p.email,
          phone: p.mobile,
        ));
      }
    } else {
      // Fallback only if local member actually has parent info
      if (member.parentName != null && member.parentName!.trim().isNotEmpty) {
        contacts.addAll(buildRosterDetailContacts(member));
      }
    }

    final isEditable = profile?.isEditable ?? true;

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: '',
              leftLabel: 'Roster',
              rightWidget: InkWell(
                onTap: isEditable ? () => _showEditSheet(context, member, profile, isEditable) : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    'Edit',
                    style: AppTextStyles.heading14.copyWith(
                      color: isEditable
                          ? AppColors.current.actionAccent
                          : AppColors.current.gray400,
                    ),
                  ),
                ),
              ),
            ),
            // Indent active loading indicator below the subheader
            if (profileState.isLoading)
              LinearProgressIndicator(
                color: AppColors.current.primary,
                backgroundColor: AppColors.current.primaryLight,
                minHeight: 3,
              ),
            Expanded(
              child: profileState.errorMessage != null && profileState.profile == null
                  ? _buildErrorView(context, profileState.errorMessage!)
                  : RefreshIndicator(
                      color: AppColors.current.primary,
                      onRefresh: () => ref.read(playerProfileProvider(memberId).notifier).refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RosterProfileSection(
                              member: member,
                              imageUrl: profile?.imageUrl ?? '',
                              jerseyNo: profile?.jerseyNo,
                              position: profile?.primaryPosition,
                              onAvatarTap: isEditable ? () => _showEditSheet(context, member, profile, isEditable) : () {},
                            ),
                            RosterActionButtons(
                              onAttendanceTap: () => context.push(
                                '${AppRoutes.roster}/${AppRoutes.rosterDetail}/${AppRoutes.rosterAttendance}',
                                extra: memberId,
                              ),
                            ),
                            const SizedBox(height: 10),
                            RosterFamilyContactsSection(
                              contacts: contacts,
                              onContactTap: (c) => _showContactDialog(context, c),
                              onAddFamilyTap: () => _showAddFamilySheet(context),
                              isLoading: profileState.isLoading,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.current.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load player profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.current.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.current.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.current.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => ref.read(playerProfileProvider(_memberId!).notifier).refresh(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sheet helpers ─────────────────────────────────────────────────────────

  void _showEditSheet(BuildContext context, RosterMember member, PlayerModel? playerProfile, bool isEditable) {
    final activeTeam = ref.read(selectedTeamProvider);
    final posLabel = (playerProfile != null && playerProfile.primaryPosition.isNotEmpty)
        ? formatPosition(playerProfile.primaryPosition)
        : member.positionFull;

    final config = PlayerFormConfig(
      playerId: member.playerId,
      teamUuid: activeTeam?.uuid ?? '',
      initialFirstName: playerProfile?.firstName ?? member.firstName,
      initialLastName: playerProfile?.lastName ?? member.lastName,
      initialJersey: playerProfile?.jerseyNo ?? member.jerseyNo,
      initialPositionLabel: posLabel,
      existingPhotoUrl: playerProfile?.imageUrl.isNotEmpty == true ? playerProfile!.imageUrl : null,
      isEditable: isEditable,
      initials: member.initials,
      onSuccess: () => ref.invalidate(playerProfileProvider(member.id)),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayerFormSheet(config: config),
    );
  }

  void _showContactDialog(BuildContext context, RosterDetailContact contact) {
    showDialog(
      context: context,
      builder: (_) => RosterContactActionDialog(contact: contact),
    );
  }

  void _showAddFamilySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RosterAddFamilySheet(memberId: _memberId!),
    );
  }
}
