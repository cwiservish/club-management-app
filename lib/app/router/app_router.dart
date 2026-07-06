import 'package:flutter/cupertino.dart'; // ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/common_providers/current_user_provider.dart';
import '../../core/models/club_event.dart';

import '../../features/splash/pages/splash_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/messages/pages/messages_page.dart';
import '../../features/messages/pages/talkjs_chat_page.dart';
import '../../features/messages/pages/create_channel_page.dart';
import '../../features/messages/pages/edit_channel_page.dart';
import '../../features/messages/models/chat_channel.dart';
import '../../features/roster/pages/roster_page.dart';
import '../../features/roster/pages/roster_detail_page.dart';
import '../../features/roster/pages/attendance_history_page.dart';
import '../../features/roster/models/roster_member.dart';
import '../../features/statistics/pages/statistics_page.dart';
import '../../features/photos/pages/photos_page.dart';
import '../../features/files/pages/files_page.dart';
import '../../features/tracking/pages/tracking_page.dart';
import '../../features/notification_preferences/pages/notification_preferences_page.dart';
import '../../features/invoice/pages/invoice_page.dart';
import '../../features/invoice/pages/invoice_form_page.dart';
import '../../features/schedule/pages/schedule_page.dart';
import '../../features/schedule/pages/league_events_listing_page.dart';
import '../../features/event_details/models/event_detail_model.dart';
import '../../features/event_details/pages/event_detail_page.dart' as ed;
import '../../features/event_details/pages/add_edit_event_page.dart';
import '../../features/event_details/pages/import_schedule_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/forgot_password_page.dart';
import '../../shell/app_shell.dart';
import '../../core/shared_widgets/profile_webview_page.dart';
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
      final userState = ref.read(currentUserProvider);
      
      debugPrint('[Router] Path: ${state.matchedLocation}, Loading: ${userState.isLoading}, HasValue: ${userState.hasValue}, User: ${userState.value?.email}');

      if (userState.isLoading) {
        return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isLoggedIn = userState.value != null;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isForgotPassword = state.matchedLocation == AppRoutes.forgotPassword;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      debugPrint('[Router] isLoggedIn: $isLoggedIn, isLoggingIn: $isLoggingIn, isForgotPassword: $isForgotPassword, isSplash: $isSplash');

      if (!isLoggedIn) {
        if (isLoggingIn || isForgotPassword) return null;
        debugPrint('[Router] Redirecting to Login');
        return AppRoutes.login;
      }

      if (isSplash || isLoggingIn) {
        debugPrint('[Router] Redirecting to Home');
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.profileDetail,
        builder: (context, state) => ProfileWebViewPage(
          url: state.extra as String,
        ),
      ),
      GoRoute(
        path: AppRoutes.newEvent,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AddEditEventPage(
            origin: (extra?['origin'] as String?) ?? 'home',
            defaultSchedulingTypeKey: extra?['defaultSchedulingTypeKey'] as int?,
            defaultEventTypeKey: extra?['defaultEventTypeKey'] as int?,
            parentEvent: extra?['parentEvent'] as ClubEvent?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.importSchedule,
        builder: (context, state) => const ImportSchedulePage(),
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
                    path: AppRoutes.scheduleLeagueDetail,
                    builder: (context, state) => LeagueEventsListingPage(
                      event: state.extra as ClubEvent,
                    ),
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
                    path: AppRoutes.rosterDetail,
                    builder: (context, state) => RosterDetailPage(
                      memberId: (state.extra as RosterMember).id,
                    ),
                    routes: [
                      GoRoute(
                        path: AppRoutes.rosterAttendance,
                        builder: (context, state) => AttendanceHistoryPage(
                          memberId: state.extra as String,
                        ),
                      ),
                    ],
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
                        TalkJSChatPage(args: state.extra as TalkJSChatArgs),
                  ),
                  GoRoute(
                    path: AppRoutes.createChannel,
                    builder: (context, state) => const CreateChannelPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.editChannel,
                    builder: (context, state) => EditChannelPage(
                      channel: state.extra as ChatChannel,
                    ),
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
                path: AppRoutes.statistics,
                builder: (context, state) => const StatisticsPage(),
              ),
              GoRoute(
                path: AppRoutes.photos,
                builder: (context, state) => const PhotosPage(),
              ),
              GoRoute(
                path: AppRoutes.files,
                builder: (context, state) => const FilesPage(),
              ),
              GoRoute(
                path: AppRoutes.tracking,
                builder: (context, state) => const TrackingPage(),
              ),
              GoRoute(
                path: AppRoutes.notificationPreferences,
                builder: (context, state) => const NotificationPreferencesPage(),
              ),
              GoRoute(
                path: AppRoutes.invoicing,
                builder: (context, state) => const InvoicePage(),
                routes: [
                  GoRoute(
                    path: AppRoutes.invoicingNew,
                    builder: (context, state) => const InvoiceFormPage(),
                  ),
                ],
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
                        activeTab: EventDetailTab.details,
                        from: state.uri.queryParameters['from'] ?? 'home',
                        initialEvent: state.extra is ClubEvent ? state.extra as ClubEvent : null,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.eventDetailAvailability,
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: ed.EventDetailPage(
                        eventId: state.pathParameters['eventId']!,
                        activeTab: EventDetailTab.availability,
                        from: state.uri.queryParameters['from'] ?? 'home',
                        initialEvent: state.extra is ClubEvent ? state.extra as ClubEvent : null,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.eventDetailEdit,
                    builder: (context, state) {
                      final extra = state.extra as Map?;
                      return AddEditEventPage(
                        editEvent: extra?['event'] as ClubEvent?,
                        origin: (extra?['from'] as String?) ?? 'home',
                        isDuplicate: (extra?['duplicate'] as bool?) ?? false,
                      );
                    },
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

