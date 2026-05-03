import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/enums/member_role.dart';
import '../models/roster_member.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/roster_provider.dart';
import '../widgets/roster_list_row.dart';
import '../widgets/roster_section_header.dart';
import '../widgets/roster_sort_bottom_sheet.dart';
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
    context.push('/roster/${AppRoutes.rosterDetail}', extra: member);
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const RosterSortBottomSheet(),
    );
  }
}
