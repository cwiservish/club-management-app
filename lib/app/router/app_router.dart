import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/common_providers/current_user_provider.dart';
import '../../core/models/chat_models.dart';
import '../../core/models/club_event.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/messages/pages/messages_page.dart';
import '../../features/roster/pages/attendance_history_page.dart';
import '../../features/roster/pages/roster_page.dart';
import '../../features/schedule/pages/event_detail_page.dart';
import '../../features/schedule/pages/event_form_page.dart';
import '../../features/schedule/pages/schedule_page.dart';
import '../../shell/app_shell.dart';
import 'app_routes.dart';

export 'app_routes.dart';

// ─── Auth Listenable ──────────────────────────────────────────────────────────

/// Bridges Riverpod → GoRouter.
/// When [notify] is called, GoRouter re-runs [redirect].
class _AuthListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ─── Router Provider ──────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable();

  // Re-run redirect whenever auth state changes.
  ref.listen(currentUserProvider, (_, __) => listenable.notify());

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      debugPrint('[Router] → ${state.matchedLocation}');
      final userState = ref.read(currentUserProvider);

      if (userState.isLoading) {
        return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (state.matchedLocation == AppRoutes.splash) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: Schedule
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) => const ScheduleScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.scheduleEventDetail,
                    builder: (context, state) =>
                        EventDetailScreen(event: state.extra as ClubEvent),
                  ),
                  GoRoute(
                    path: AppRoutes.scheduleEventForm,
                    builder: (context, state) =>
                        EventFormScreen(event: state.extra as ClubEvent?),
                  ),
                ],
              ),
            ],
          ),

          // Tab 2: Roster
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

          // Tab 3: Messages
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                builder: (context, state) => const MessagesScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.messagesChatDetail,
                    builder: (context, state) =>
                        ChatDetailScreen(thread: state.extra as ChatThread),
                  ),
                ],
              ),
            ],
          ),

        ],
      ),

    ],
  );
});

