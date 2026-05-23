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
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const TeamInfoCard(
                              teamName: '12 Girls ECNL RL',
                              record: 'Record: 13-9-3',
                            ),
                            const SizedBox(height: 24),
                            SettingsMenuItem(
                              title: 'Photos',
                              onTap: () => context.push(AppRoutes.photos),
                            ),
                            const SizedBox(height: 12),
                            SettingsMenuItem(
                              title: 'Files',
                              onTap: () => context.push(AppRoutes.files),
                            ),
                            const SizedBox(height: 12),
                            SettingsMenuItem(
                              title: 'Notification Preferences',
                              onTap: () => context.push(AppRoutes.notificationPreferences),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
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
