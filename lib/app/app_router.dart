import 'package:go_router/go_router.dart';

import '../features/files/pages/files_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/invoicing/pages/invoicing_page.dart';
import '../features/messages/pages/messages_page.dart';
import '../features/more/pages/more_page.dart';
import '../features/notifications/pages/notification_prefs_page.dart';
import '../features/photos/pages/photos_page.dart';
import '../features/registration/pages/registration_page.dart';
import '../features/roster/pages/attendance_history_page.dart';
import '../features/roster/pages/roster_page.dart';
import '../features/schedule/pages/event_detail_page.dart';
import '../features/schedule/pages/schedule_page.dart';
import '../features/statistics/pages/statistics_page.dart';
import '../features/team/pages/team_detail_page.dart';
import '../features/tracking/pages/tracking_page.dart';
import '../shell/app_shell.dart';


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
          AppShell(navigationShell: navigationShell),
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

