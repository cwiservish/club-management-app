import 'package:flutter/material.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../widgets/team_info_card.dart';
import '../widgets/home_menu_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Column(
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
                            HomeMenuItem(title: 'Photos'),
                            SizedBox(height: 12),
                            HomeMenuItem(title: 'Statistics'),
                            SizedBox(height: 12),
                            HomeMenuItem(title: 'Files'),
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
                            HomeMenuItem(title: 'Invoicing'),
                            SizedBox(height: 12),
                            HomeMenuItem(title: 'Tracking'),
                            SizedBox(height: 12),
                            HomeMenuItem(title: 'Registration Insurance'),
                            SizedBox(height: 12),
                            HomeMenuItem(title: 'Recruiting'),
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
                            HomeMenuItem(title: 'Notification Preferences'),
                          ],
                        ),
                      ),
                      SizedBox(height: 48), // Bottom padding
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

