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
              child: state.isLoading && state.allMembers.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.current.primary,
                      ),
                    )
                  : state.errorMessage != null && state.allMembers.isEmpty
                      ? Center(
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
                                  'Failed to load roster players',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.current.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.errorMessage!,
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
                                  onPressed: () => ref.read(rosterProvider.notifier).refresh(),
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.current.primary,
                          onRefresh: () => ref.read(rosterProvider.notifier).refresh(),
                          child: players.isEmpty && staff.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.people_outline,
                                              size: 64,
                                              color: AppColors.current.gray400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No players found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.current.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Make sure this team has players registered.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.current.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  children: [
                                    RosterSectionHeader(
                                      title: 'Players',
                                      count: players.length,
                                      onSortTap: () => _showSortSheet(context),
                                    ),
                                    if (players.isNotEmpty)
                                      ...players.map((m) => RosterListRow(
                                            member: m,
                                            onTap: () => _openDetail(context, m),
                                          )),
                                    RosterSectionHeader(
                                      title: 'Staff',
                                      count: staff.length,
                                      onSortTap: () => _showSortSheet(context),
                                    ),
                                    if (staff.isNotEmpty)
                                      ...staff.map((m) => RosterListRow(
                                            member: m,
                                            onTap: null,
                                          )),
                                  ],
                                ),
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
