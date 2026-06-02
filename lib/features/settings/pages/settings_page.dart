import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../widgets/team_info_card.dart';
import '../widgets/settings_menu_item.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final activeTeam = ref.watch(selectedTeamProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.current.background,
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(),
              SubHeader(
                title: '',
                leftLabel: 'Home',
                onLeftTap: () => context.go(AppRoutes.home),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: AppColors.current.surface,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TeamInfoCard(
                            team: activeTeam,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(
                          color: AppColors.current.border,
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              SettingsMenuItem(
                                title: 'Photos',
                                onTap: () => context.push(AppRoutes.photos),
                              ),
                              const SizedBox(height: 12),
                              SettingsMenuItem(
                                title: 'Files',
                                onTap: () => context.push(AppRoutes.files),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColors.current.border,
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SettingsMenuItem(
                            title: 'Notification Preferences',
                            onTap: () => context.push(AppRoutes.notificationPreferences),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: AppColors.current.border,
                          height: 1,
                          thickness: 1,
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
      ),
    );
  }
}
