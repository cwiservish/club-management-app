import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/member_role.dart';
import '../../../core/models/roster_member.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/roster_provider.dart';
import '../widgets/roster_detail_headers.dart';
import '../widgets/roster_detail_rows.dart';
import '../widgets/roster_list_row.dart';
import '../widgets/roster_section_header.dart';
import '../widgets/roster_sub_header.dart';

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
            const RosterSubHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (players.isNotEmpty) ...[
                    RosterSectionHeader(
                      title: 'Players',
                      count: players.length,
                      onSortTap: () => _showSortSheet(context),
                    ),
                    ...players.map((m) => RosterListRow(
                          member: m,
                          onTap: () => _openDetail(context, m),
                        )),
                  ],
                  if (staff.isNotEmpty) ...[
                    RosterSectionHeader(
                      title: 'Staff',
                      count: staff.length,
                      onSortTap: () => _showSortSheet(context),
                    ),
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

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SortBottomSheet(),
    );
  }
}

// ─── Sort Bottom Sheet ────────────────────────────────────────────────────────

class _SortBottomSheet extends StatefulWidget {
  const _SortBottomSheet();

  @override
  State<_SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<_SortBottomSheet> {
  String _selected = 'First Name';

  static const _options = [
    'First Name',
    'Last Name',
    'Position',
    'Gender',
    'Number',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.current.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Sort Roster By',
                  style: AppTextStyles.heading18.copyWith(
                    color: AppColors.current.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.current.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.current.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.current.border.withOpacity(0.5)),
          // Options
          Padding(
            padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              children: _options.map((option) {
                final isSelected = _selected == option;
                return GestureDetector(
                  onTap: () => setState(() => _selected = option),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.current.primaryLight
                          : AppColors.current.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.current.primary.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          option,
                          style: AppTextStyles.body16.copyWith(
                            color: isSelected
                                ? AppColors.current.primary
                                : AppColors.current.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.current.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.current.isDark
                                  ? AppColors.current.gray900
                                  : Colors.white,
                              weight: 700,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
