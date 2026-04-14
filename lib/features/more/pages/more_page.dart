import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme.dart';

/// Playbook365 — More Screen
/// Hub screen for all secondary features accessible from the bottom nav More tab.

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSection(context, 'Team Management', [
                      _Item(Icons.sports_soccer, 'Team Detail', AppColors.primary,
                          () => context.push('/more/${AppRoutes.moreTeamDetail}')),
                      _Item(Icons.bar_chart_outlined, 'Statistics', AppColors.success,
                          () => context.push('/more/${AppRoutes.moreStatistics}')),
                      _Item(Icons.people_outline, 'Player Attendance', AppColors.purple,
                          () => context.push('/roster/${AppRoutes.rosterAttendance}')),
                      _Item(Icons.track_changes_outlined, 'Tracking', AppColors.warning,
                          () => context.push('/more/${AppRoutes.moreTracking}')),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(context, 'Media & Files', [
                      _Item(Icons.photo_library_outlined, 'Photos', AppColors.sky,
                          () => context.push('/more/${AppRoutes.morePhotos}')),
                      _Item(Icons.folder_outlined, 'Files', AppColors.warning,
                          () => context.push('/more/${AppRoutes.moreFiles}')),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(context, 'Finance & Admin', [
                      _Item(Icons.receipt_long_outlined, 'Invoicing', AppColors.success,
                          () => context.push('/more/${AppRoutes.moreInvoicing}')),
                      _Item(Icons.badge_outlined, 'Registration & Insurance', AppColors.primary,
                          () => context.push('/more/${AppRoutes.moreRegistration}')),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(context, 'Settings', [
                      _Item(Icons.notifications_outlined, 'Notification Preferences',
                          AppColors.purple,
                          () => context.push('/more/${AppRoutes.moreNotifications}')),
                      _Item(Icons.person_outline, 'Edit Profile', AppColors.gray500, () {}),
                      _Item(Icons.help_outline, 'Help & Support', AppColors.gray500, () {}),
                      _Item(Icons.logout, 'Sign Out', AppColors.error, () {}),
                    ]),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Playbook365 v1.0.0', style: AppTextStyles.labelSmall),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: const Row(
        children: [
          Text('More', style: AppTextStyles.headlineLarge),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xlRadius,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Text('JD',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jamie Davis',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('Parent · U14 Boys Premier',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.primaryMid)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_Item> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:  EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title.toUpperCase(),),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isFirst = i == 0;
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.vertical(
                      top: isFirst ?  Radius.circular(AppRadius.lg) : Radius.zero,
                      bottom: isLast ?  Radius.circular(AppRadius.lg) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: 13),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              borderRadius: AppRadius.smRadius,
                            ),
                            child: Icon(item.icon, color: item.color, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(item.label,),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.gray400, size: 18),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 64, color: AppColors.gray100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Item(this.icon, this.label, this.color, this.onTap);
}
