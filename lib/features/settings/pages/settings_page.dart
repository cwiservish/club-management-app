import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../widgets/team_info_card.dart';
import '../widgets/settings_menu_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
             AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
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
                              onTap: () => context.push(
                                '${AppRoutes.settings}/${AppRoutes.settingsEvents}',
                              ),
                            ),
                            SizedBox(height: 12),
                            SettingsMenuItem(title: 'Statistics'),
                            SizedBox(height: 12),
                            SettingsMenuItem(title: 'Files'),
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
                            SettingsMenuItem(title: 'Invoicing'),
                            SizedBox(height: 12),
                            SettingsMenuItem(title: 'Tracking'),
                            SizedBox(height: 12),
                            SettingsMenuItem(title: 'Registration Insurance'),
                            SizedBox(height: 12),
                            SettingsMenuItem(title: 'Recruiting'),
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
                            SettingsMenuItem(title: 'Notification Preferences'),
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
