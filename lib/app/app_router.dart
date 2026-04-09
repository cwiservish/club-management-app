import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/shared_widgets.dart';
import '../screens/home_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/roster_screen.dart';
import '../screens/messages_screens.dart';
import '../screens/more_screen.dart';
import '../screens/team_event_screens.dart' show TeamDetailScreen, EventDetailScreen;
import '../screens/statistics_screen.dart';
import '../screens/photos_screen.dart';
import '../screens/files_screen.dart';
import '../screens/invoicing_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/notification_prefs_screen.dart';
import '../screens/tracking_screen.dart';
import '../screens/player_attendance_screen.dart';

// ─── Route Paths ──────────────────────────────────────────────────────────────

abstract class AppRoutes {
  static const home = '/home';
  static const schedule = '/schedule';
  static const scheduleEventDetail = 'event/:id';
  static const roster = '/roster';
  static const rosterAttendance = 'attendance';
  static const messages = '/messages';
  static const more = '/more';
  static const moreStatistics = 'statistics';
  static const morePhotos = 'photos';
  static const moreFiles = 'files';
  static const moreInvoicing = 'invoicing';
  static const moreRegistration = 'registration';
  static const moreNotifications = 'notifications';
  static const moreTracking = 'tracking';
  static const moreTeamDetail = 'team-detail';
}

// ─── Router ───────────────────────────────────────────────────────────────────

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _AppShell(navigationShell: navigationShell),
      branches: [
        // ── Tab 0: Home ──────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // ── Tab 1: Schedule ──────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.schedule,
              builder: (context, state) => const ScheduleScreen(),
              routes: [
                GoRoute(
                  path: AppRoutes.scheduleEventDetail,
                  builder: (context, state) => const EventDetailScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Tab 2: Roster ────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.roster,
              builder: (context, state) => const RosterScreen(),
              routes: [
                GoRoute(
                  path: AppRoutes.rosterAttendance,
                  builder: (context, state) => const PlayerAttendanceScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Tab 3: Messages ──────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.messages,
              builder: (context, state) => const MessagesScreen(),
            ),
          ],
        ),

        // ── Tab 4: More ──────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.more,
              builder: (context, state) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: AppRoutes.moreStatistics,
                  builder: (context, state) => const StatisticsScreen(),
                ),
                GoRoute(
                  path: AppRoutes.morePhotos,
                  builder: (context, state) => const PhotosScreen(),
                ),
                GoRoute(
                  path: AppRoutes.moreFiles,
                  builder: (context, state) => const FilesScreen(),
                ),
                GoRoute(
                  path: AppRoutes.moreInvoicing,
                  builder: (context, state) => const InvoicingScreen(),
                ),
                GoRoute(
                  path: AppRoutes.moreRegistration,
                  builder: (context, state) => const RegistrationScreen(),
                ),
                GoRoute(
                  path: AppRoutes.moreNotifications,
                  builder: (context, state) => const NotificationPrefsScreen(),
                ),
                GoRoute(
                  path: AppRoutes.moreTracking,
                  builder: (context, state) => const TrackingScreen(),
                ),
                GoRoute(
                  path: AppRoutes.moreTeamDetail,
                  builder: (context, state) => const TeamDetailScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// ─── Shell Widget (bottom nav) ────────────────────────────────────────────────
// TODO: Step 11 — replace with full shell/app_shell.dart

class _AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _AppShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
