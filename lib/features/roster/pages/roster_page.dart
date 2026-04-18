import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/member_role.dart';
import '../../../core/models/roster_member.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../providers/roster_provider.dart';
import '../widgets/roster_detail_headers.dart';
import '../widgets/roster_detail_rows.dart';
import '../widgets/roster_list_row.dart';
import '../widgets/roster_section_header.dart';

// ─── Roster List ──────────────────────────────────────────────────────────────

class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final state   = ref.watch(rosterProvider);
    final players = state.filtered.where((m) => m.role == MemberRole.player).toList();
    final staff   = state.filtered.where((m) => m.role == MemberRole.staff).toList();

    return Scaffold(
      backgroundColor: AppColors.current.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (players.isNotEmpty) ...[
                    RosterSectionHeader(title: 'Players', count: players.length),
                    ...players.map((m) => RosterListRow(
                          member: m,
                          onTap: () => _openDetail(context, m),
                        )),
                  ],
                  if (staff.isNotEmpty) ...[
                    RosterSectionHeader(title: 'Staff', count: staff.length),
                    ...staff.map((m) => RosterListRow(
                          member: m,
                          onTap: () => _openDetail(context, m),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, RosterMember member) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _MemberDetailScreen(member: member)),
    );
  }
}

// ─── Member Detail ────────────────────────────────────────────────────────────

class _MemberDetailScreen extends StatelessWidget {
  final RosterMember member;
  const _MemberDetailScreen({required this.member});

  @override
  Widget build(BuildContext context) {
    final contactName = member.parentName ?? member.fullName;

    return Scaffold(
      backgroundColor: AppColors.current.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const RosterDetailTopBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _MemberPhoto(member: member),
                  RosterInfoRow(
                    primary: member.fullName,
                    secondary: member.jerseyNumber != null
                        ? '#${member.jerseyNumber}'
                        : member.staffTitle,
                  ),
                  RosterNavRow(label: 'Statistics'),
                  RosterDetailSectionHeader(title: 'Contact Information'),
                  RosterInfoRow(
                    primary: '$contactName — ${member.parentName != null ? "Mom" : member.displayRole}',
                    secondary: member.email,
                  ),
                  RosterInfoRow(
                    primary: '$contactName — ${member.parentName != null ? "Mom" : member.displayRole}',
                    secondary: member.phone,
                  ),
                  const SizedBox(height: 4),
                  const RosterActionLink(label: '+ Add Family Member'),
                  const RosterActionLink(label: '+ Add to Phone Contacts'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Member photo hero ────────────────────────────────────────────────────────

class _MemberPhoto extends StatelessWidget {
  final RosterMember member;
  const _MemberPhoto({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 183,
      width: double.infinity,
      color: AppColors.current.card,
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 72,
          fontWeight: FontWeight.w900,
          color: AppColors.current.textPrimary.withOpacity(0.15),
        ),
      ),
    );
  }
}
