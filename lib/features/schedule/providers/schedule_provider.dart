import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/club_event.dart';
import '../../../core/enums/event_type.dart';
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

  const ScheduleState({
    required this.events,
    required this.selectedDate,
    required this.displayMonth,
    this.filter,
    required this.monthView,
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
  }) {
    return ScheduleState(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      displayMonth: displayMonth ?? this.displayMonth,
      filter: filter == _scheduleSentinel ? this.filter : filter as EventType?,
      monthView: monthView ?? this.monthView,
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
    final now = DateTime.now();
    return ScheduleState(
      events: ref.read(scheduleServiceProvider).getEvents(),
      selectedDate: now,
      displayMonth: DateTime(now.year, now.month, 1),
      monthView: false,
    );
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
}

// ─── Providers ────────────────────────────────────────────────────────────────

final scheduleServiceProvider =
    Provider<ScheduleService>((ref) => ScheduleService());

final scheduleProvider =
    NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);
