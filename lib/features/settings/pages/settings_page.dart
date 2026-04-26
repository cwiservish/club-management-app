import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../widgets/team_info_card.dart';
import '../widgets/settings_menu_item.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: AppColors.current.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: AppColors.current.surface,
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            TeamInfoCard(
                              teamName: '12 Girls ECNL RL',
                              record: 'Record: 13-9-3',
                            ),
                            SizedBox(height: 24),
                            SettingsMenuItem(
                              title: 'Photos',
                              onTap: () => context.push(AppRoutes.photos),
                            ),
                            SizedBox(height: 12),
                            SettingsMenuItem(
                              title: 'Statistics',
                              onTap: () => context.push(AppRoutes.statistics),
                            ),
                            SizedBox(height: 12),
                            SettingsMenuItem(
                              title: 'Files',
                              onTap: () => context.push(AppRoutes.files),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Divider(height: 1, thickness: 1),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SettingsMenuItem(
                              title: 'Invoicing',
                              onTap: () => context.push(AppRoutes.invoicing),
                            ),
                            SizedBox(height: 12),
                            SettingsMenuItem(
                              title: 'Tracking',
                              onTap: () => context.push(AppRoutes.tracking),
                            ),
                            SizedBox(height: 12),
                            SettingsMenuItem(title: 'Registration Insurance'),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Divider(height: 1, thickness: 1),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SettingsMenuItem(
                              title: 'Notification Preferences',
                              onTap: () => context.push(AppRoutes.notificationPreferences),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 48),
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
}
