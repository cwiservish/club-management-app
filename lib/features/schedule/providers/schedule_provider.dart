import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/club_event.dart';
import '../../../core/enums/event_type.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/common_providers/event_refresh_provider.dart';
import '../../../core/network/api_client.dart';
import '../models/schedule_models.dart';
import '../services/schedule_service.dart';

export '../models/schedule_models.dart';

const _scheduleSentinel = Object();

class ScheduleState {
  final List<ClubEvent> events;
  final DateTime selectedDate;
  final DateTime displayMonth;
  final EventType? filter;
  final bool monthView;
  final bool isLoading;
  final String? errorMessage;

  const ScheduleState({
    required this.events,
    required this.selectedDate,
    required this.displayMonth,
    this.filter,
    required this.monthView,
    this.isLoading = false,
    this.errorMessage,
  });

  // ── Filtered + sorted event list ─────────────────────────────────────────

  List<ClubEvent> get filtered {
    return events
        .where((e) => filter == null || e.type == filter)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<ClubEvent> eventsForDate(DateTime date) {
    return filtered
        .where((e) =>
            e.dateTime.year == date.year &&
            e.dateTime.month == date.month &&
            e.dateTime.day == date.day)
        .toList();
  }

  List<DateTime> get weekDays {
    final monday =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  // ── Pre-computed month sections for the list view ────────────────────────
  // Groups and sorts events by month. The page renders this directly.

  List<ScheduleMonthSection> get monthSections {
    final grouped = <DateTime, List<ClubEvent>>{};
    for (final event in filtered) {
      final key = DateTime(event.dateTime.year, event.dateTime.month);
      grouped.putIfAbsent(key, () => []).add(event);
    }
    for (final events in grouped.values) {
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => a.year != b.year
          ? a.year.compareTo(b.year)
          : a.month.compareTo(b.month));
    return sortedKeys
        .map((date) => ScheduleMonthSection(
              monthDate: date,
              monthName: _monthName(date.month),
              events: grouped[date]!,
            ))
        .toList();
  }

  ScheduleState copyWith({
    List<ClubEvent>? events,
    DateTime? selectedDate,
    DateTime? displayMonth,
    Object? filter = _scheduleSentinel,
    bool? monthView,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ScheduleState(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      displayMonth: displayMonth ?? this.displayMonth,
      filter: filter == _scheduleSentinel ? this.filter : filter as EventType?,
      monthView: monthView ?? this.monthView,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _monthName(int month) => const [
      'January', 'February', 'March',    'April',
      'May',     'June',     'July',     'August',
      'September','October', 'November', 'December',
    ][month - 1];

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ScheduleNotifier extends Notifier<ScheduleState> {
  @override
  ScheduleState build() {
    final activeTeam = ref.watch(selectedTeamProvider);
    final now = DateTime.now();

    // Fetch reactively when team changes
    if (activeTeam != null) {
      Future.microtask(() => fetchEvents(activeTeam.uuid));
    }

    // Refresh when any feature signals that event data has changed
    ref.listen(eventRefreshSignalProvider, (_, __) {
      final team = ref.read(selectedTeamProvider);
      if (team != null) Future.microtask(() => fetchEvents(team.uuid));
    });

    // Preserve existing events across rebuilds so the UI never flashes blank.
    final previous = stateOrNull;
    return ScheduleState(
      events:       previous?.events ?? const [],
      selectedDate: previous?.selectedDate ?? now,
      displayMonth: previous?.displayMonth ?? DateTime(now.year, now.month, 1),
      monthView:    previous?.monthView ?? false,
      isLoading: activeTeam != null,
    );
  }

  /// Fetch events from QA API.
  Future<void> fetchEvents(String teamUuid) async {
    // Keep existing events visible — no blank screen during refresh
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final fetched = await ref.read(scheduleServiceProvider).fetchScheduleEvents(teamUuid);
      state = state.copyWith(
        events: fetched,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Triggers API refresh.
  Future<void> refresh() async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam != null) {
      await fetchEvents(activeTeam.uuid);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectDate(DateTime date) => state = state.copyWith(selectedDate: date);
  void prevMonth() => state = state.copyWith(
      displayMonth:
          DateTime(state.displayMonth.year, state.displayMonth.month - 1, 1));
  void nextMonth() => state = state.copyWith(
      displayMonth:
          DateTime(state.displayMonth.year, state.displayMonth.month + 1, 1));
  void setFilter(EventType? f) => state = state.copyWith(filter: f);
  void setMonthView(bool v) => state = state.copyWith(monthView: v);

  void updateRsvp(String eventId, String status) {
    const currentUserId = 'me';

    final newEvents = state.events.map((e) {
      if (e.id != eventId) return e;

      final newYes   = e.rsvpYes.where((id) => id != currentUserId).toList();
      final newNo    = e.rsvpNo.where((id) => id != currentUserId).toList();
      final newMaybe = e.rsvpMaybe.where((id) => id != currentUserId).toList();

      if (status == 'going') newYes.add(currentUserId);
      if (status == 'no')    newNo.add(currentUserId);
      if (status == 'maybe') newMaybe.add(currentUserId);

      return e.copyWith(rsvpYes: newYes, rsvpNo: newNo, rsvpMaybe: newMaybe);
    }).toList();

    state = state.copyWith(events: newEvents);
  }

  /// Asynchronously saves RSVP status on the server.
  /// Optimistically updates the UI immediately; reverts on failure.
  Future<({bool success, String message})> saveEventRsvp({
    required ClubEvent event,
    required ClubEventRsvpTarget target,
    required String status, // 'going', 'maybe', 'no'
  }) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      return (success: false, message: 'No selected team found');
    }

    // Derive previous status for revert
    final previousStatus = event.rsvpYes.contains('me') ? 'going'
        : event.rsvpNo.contains('me') ? 'no'
        : event.rsvpMaybe.contains('me') ? 'maybe'
        : '';

    // Optimistic update — instant UI response
    updateRsvp(event.id, status);

    int attendanceValue = 0;
    if (status == 'going') attendanceValue = 1;
    if (status == 'maybe') attendanceValue = 2;
    if (status == 'no') attendanceValue = 0;

    try {
      final result = await ref.read(scheduleServiceProvider).saveEventRsvp(
        teamUuid: activeTeam.uuid,
        teamEventSessionId: event.dbId ?? 0,
        target: target,
        attendance: attendanceValue,
      );

      if (result.success) {
        // Background refresh — events not cleared so no loader is shown.
        // Signal home to update its counts too.
        fetchEvents(activeTeam.uuid);
        ref.read(eventRefreshSignalProvider.notifier).signal();
        return (success: true, message: result.message.isNotEmpty ? result.message : 'RSVP updated successfully.');
      } else {
        // Revert optimistic update
        updateRsvp(event.id, previousStatus);
        return (success: false, message: result.message.isNotEmpty ? result.message : 'Failed to update RSVP.');
      }
    } catch (e) {
      // Revert optimistic update
      updateRsvp(event.id, previousStatus);
      return (success: false, message: e.toString());
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ScheduleService(apiClient);
});

final scheduleProvider =
    NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);
