import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/event_type.dart';
import '../../../core/models/club_event.dart';
import '../../../core/local_storage/app_storage.dart';
import '../../../core/network/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/common_providers/user_teams_provider.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/home_models.dart';
import '../services/home_service.dart';
import '../../event_details/providers/event_detail_provider.dart';
import '../../event_details/services/event_detail_service.dart';

export '../models/home_models.dart';

// ─── State ────────────────────────────────────────────────────────────────────

const _sentinel = Object();

class HomeState {
  final List<ClubEvent> events;

  /// URL of the sponsor banner image shown at the top of the Events list.
  final String? bannerImageUrl;

  /// Stores the current user's RSVP choice per event ID.
  final Map<String, HomeRsvp> userRsvps;

  final EventType? filter;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    required this.events,
    this.bannerImageUrl,
    required this.userRsvps,
    this.filter,
    this.isLoading = false,
    this.errorMessage,
  });

  // ── Filtered event list ──────────────────────────────────────────────────

  List<ClubEvent> get filtered {
    return events
        .where((e) => filter == null || e.type == filter)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // ── Business logic: compute view-models ─────────────────────────────────
  // All count arithmetic and RSVP derivation lives here — widgets are dumb.

  List<HomeCardViewModel> get viewModels {
    return filtered.map((event) {
      final userChoice = userRsvps[event.id] ?? HomeRsvp.none;

      // Base counts from shared ClubEvent model
      int going = event.rsvpYes.length;
      int maybe = event.rsvpMaybe.length;
      int no    = event.rsvpNo.length;

      // Only adjust counts if user has changed their selection from what was parsed.
      final bool hadGoing = event.rsvpYes.contains('me');
      final bool hadMaybe = event.rsvpMaybe.contains('me');
      final bool hadNo = event.rsvpNo.contains('me');

      if (userChoice == HomeRsvp.going && !hadGoing) going++;
      if (userChoice == HomeRsvp.maybe && !hadMaybe) maybe++;
      if (userChoice == HomeRsvp.no && !hadNo) no++;

      if (hadGoing && userChoice != HomeRsvp.going) going--;
      if (hadMaybe && userChoice != HomeRsvp.maybe) maybe--;
      if (hadNo && userChoice != HomeRsvp.no) no--;

      // Format date / time strings
      final dt  = event.dateTime;
      final end = event.endTime;
      final date = '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
      final timeRange = (event.timeLabel != null && event.timeLabel!.isNotEmpty)
          ? event.timeLabel!
          : '${_fmtTime(dt)} - ${_fmtTime(end)}';

      return HomeCardViewModel(
        id:           event.id,
        date:         date,
        timeRange:    timeRange,
        type:         event.title,
        location:     event.location,
        goingCount:   going,
        maybeCount:   maybe,
        noCount:      no,
        selectedRsvp: userChoice,
        latitude:     event.latitude,
        longitude:    event.longitude,
        requiresPlayerSelection: event.requiresPlayerSelection,
        rsvpTargets:  event.rsvpTargets,
        scheduleGameId: event.scheduleGameId,
      );
    }).toList();
  }

  HomeState copyWith({
    List<ClubEvent>? events,
    Object? bannerImageUrl = _sentinel,
    Map<String, HomeRsvp>? userRsvps,
    Object? filter = _sentinel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      events:    events    ?? this.events,
      bannerImageUrl: bannerImageUrl == _sentinel ? this.bannerImageUrl : bannerImageUrl as String?,
      userRsvps: userRsvps ?? this.userRsvps,
      filter:    filter == _sentinel ? this.filter : filter as EventType?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fmtTime(DateTime t) {
  final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
  final hStr = h.toString().padLeft(2, '0');
  final mStr = t.minute.toString().padLeft(2, '0');
  final period = t.hour >= 12 ? 'PM' : 'AM';
  return '$hStr : $mStr $period';
}

String _monthName(int month) => const [
      'January', 'February', 'March',    'April',
      'May',     'June',     'July',     'August',
      'September','October', 'November', 'December',
    ][month - 1];

// ─── Notifier ─────────────────────────────────────────────────────────────────

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    final activeTeam = ref.watch(selectedTeamProvider);

    // Fetch reactively when team changes
    if (activeTeam != null) {
      Future.microtask(() => fetchEvents(activeTeam.uuid));
    }

    return HomeState(
      events:    const [],
      userRsvps: const {},
      isLoading: activeTeam != null,
    );
  }

  /// Fetches events for the selected team from QA API.
  Future<void> fetchEvents(String teamUuid) async {
    state = state.copyWith(isLoading: true, errorMessage: null, events: []);
    try {
      final result = await ref.read(homeServiceProvider).fetchEvents(teamUuid);
      final fetched = result.events;
      
      // Initialize RSVP choices mapping based on whether parsed lists contain 'me'
      final Map<String, HomeRsvp> initialRsvps = {};
      for (final event in fetched) {
        if (event.rsvpYes.contains('me')) {
          initialRsvps[event.id] = HomeRsvp.going;
        } else if (event.rsvpMaybe.contains('me')) {
          initialRsvps[event.id] = HomeRsvp.maybe;
        } else if (event.rsvpNo.contains('me')) {
          initialRsvps[event.id] = HomeRsvp.no;
        } else {
          initialRsvps[event.id] = HomeRsvp.none;
        }
      }

      state = state.copyWith(
        events: fetched,
        bannerImageUrl: result.bannerImageUrl,
        userRsvps: initialRsvps,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }


  /// Toggle RSVP: tapping the same option again deselects it.
  void toggleRsvp(String eventId, HomeRsvp rsvp) {
    final current = state.userRsvps[eventId] ?? HomeRsvp.none;
    final next    = current == rsvp ? HomeRsvp.none : rsvp;

    state = state.copyWith(
      userRsvps: {...state.userRsvps, eventId: next},
    );
  }

  /// Asynchronously saves RSVP status on the server and refreshes the home event list.
  Future<({bool success, String message})> saveEventRsvp({
    required ClubEvent event,
    required ClubEventRsvpTarget target,
    required HomeRsvp rsvp,
  }) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      return (success: false, message: 'No selected team found');
    }

    int attendanceValue = 0;
    if (rsvp == HomeRsvp.going) attendanceValue = 1;
    if (rsvp == HomeRsvp.maybe) attendanceValue = 2;
    if (rsvp == HomeRsvp.no) attendanceValue = 0;

    try {
      final service = ref.read(eventDetailServiceProvider);
      final response = await service.saveEventAttendee(
        EventAttendeeSaveRequest(
          teamUuid: activeTeam.uuid,
          teamEventId: event.dbId ?? 0,
          attendeeType: target.attendeeType,
          customerId: target.customerId.toString(),
          playerId: target.playerId ?? 0,
          notes: target.notes,
          attendance: attendanceValue,
        ),
      );

      if (response.success) {
        // Optimistically update local RSVP choice
        final Map<String, HomeRsvp> updatedRsvps = {...state.userRsvps, event.id: rsvp};
        state = state.copyWith(userRsvps: updatedRsvps);
        
        // Refresh the event list silently to sync everything
        await refresh();
        
        return (success: true, message: response.message.isNotEmpty ? response.message : 'RSVP updated successfully.');
      } else {
        return (success: false, message: response.message.isNotEmpty ? response.message : 'Failed to update RSVP.');
      }
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }

  void setFilter(EventType? f) => state = state.copyWith(filter: f);

  /// Triggers API refreshes for home data (e.g. active teams) and reloads local events.
  Future<void> refresh() async {
    try {
      var token = ref.read(authTokenProvider);
      if (token == null) {
        token = await ref.read(appStorageProvider).readToken();
        if (token != null) {
          ref.read(authTokenProvider.notifier).setToken(token);
        }
      }

      if (token != null) {
        final authService = ref.read(authServiceProvider);
        final teams = await authService.fetchTeams(token);
        await ref.read(appStorageProvider).saveTeams(teams);
        ref.invalidate(userTeamsProvider);
      }
    } catch (e) {
      // Print/log the error so that developers can see it, but don't disrupt the user UI.
      debugPrint('Error refreshing home data: $e');
    } finally {
      // Reload the events list
      final activeTeam = ref.read(selectedTeamProvider);
      if (activeTeam != null) {
        await fetchEvents(activeTeam.uuid);
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final homeServiceProvider = Provider<HomeService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return HomeService(apiClient);
});

final homeProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
