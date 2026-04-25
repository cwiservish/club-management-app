import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/common_providers/current_user_provider.dart';
import '../../core/models/chat_models.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/messages/pages/messages_page.dart';
import '../../features/messages/pages/chat_detail_page.dart';
import '../../features/roster/pages/roster_page.dart';
import '../../features/roster/pages/roster_detail_page.dart';
import '../../features/roster/models/roster_member.dart';
import '../../features/invoice/pages/invoice_page.dart';
import '../../features/schedule/pages/schedule_page.dart';
import '../../features/event_details/pages/event_detail_page.dart' as ed;
import '../../features/event_details/pages/event_edit_page.dart';
import '../../shell/app_shell.dart';
import 'app_routes.dart';

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
                    path: AppRoutes.rosterDetail,
                    builder: (context, state) => RosterDetailPage(
                      memberId: (state.extra as RosterMember).id,
                    ),
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

          // Branch 4: Settings (no bottom nav tab — index 4 keeps all tabs deselected)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: AppRoutes.invoiceNew,
                builder: (context, state) => const InvoicePage(),
              ),
            ],
          ),

          // Branch 5: Event Details (independent feature, keeps all tabs deselected)
          StatefulShellBranch(
            routes: [
              // Dummy non-parameterized route to satisfy GoRouter's requirement that
              // the default location of a branch cannot be parameterized.
              GoRoute(
                path: '/_event_details_root',
                builder: (context, state) => const SizedBox.shrink(),
              ),
              GoRoute(
                path: AppRoutes.eventDetailBase,
                // If user just goes to /event/:eventId, we redirect them to details
                redirect: (context, state) {
                  if (state.matchedLocation == state.uri.path) {
                    return AppRoutes.eventDetails(state.pathParameters['eventId']!);
                  }
                  return null;
                },
                routes: [
                  GoRoute(
                    path: AppRoutes.eventDetailDetails,
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: ed.EventDetailPage(
                        eventId: state.pathParameters['eventId']!,
                        activeTab: ed.EventDetailTab.details,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.eventDetailAvailability,
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: ed.EventDetailPage(
                        eventId: state.pathParameters['eventId']!,
                        activeTab: ed.EventDetailTab.availability,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.eventDetailAssignments,
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: ed.EventDetailPage(
                        eventId: state.pathParameters['eventId']!,
                        activeTab: ed.EventDetailTab.assignments,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.eventDetailEdit,
                    builder: (context, state) => EventEditPage(
                      eventId: state.pathParameters['eventId']!,
                    ),
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

