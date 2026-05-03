import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/event_type.dart';
import '../../../core/models/club_event.dart';
import '../models/home_models.dart';
import '../services/home_service.dart';

export '../models/home_models.dart';

// ─── State ────────────────────────────────────────────────────────────────────

const _sentinel = Object();

class HomeState {
  final List<ClubEvent> events;

  /// Stores the current user's RSVP choice per event ID.
  final Map<String, HomeRsvp> userRsvps;

  final EventType? filter;

  const HomeState({
    required this.events,
    required this.userRsvps,
    this.filter,
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

      // Add the current user's vote on top
      if (userChoice == HomeRsvp.going) going++;
      if (userChoice == HomeRsvp.maybe) maybe++;
      if (userChoice == HomeRsvp.no)    no++;

      // Format date / time strings
      final dt  = event.dateTime;
      final end = event.endTime;
      final date = '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
      final timeRange = '${_fmtTime(dt)} - ${_fmtTime(end)}';

      return HomeCardViewModel(
        id:           event.id,
        date:         date,
        timeRange:    timeRange,
        type:         event.typeLabel,
        location:     event.location,
        goingCount:   going,
        maybeCount:   maybe,
        noCount:      no,
        selectedRsvp: userChoice,
      );
    }).toList();
  }

  HomeState copyWith({
    List<ClubEvent>? events,
    Map<String, HomeRsvp>? userRsvps,
    Object? filter = _sentinel,
  }) {
    return HomeState(
      events:    events    ?? this.events,
      userRsvps: userRsvps ?? this.userRsvps,
      filter:    filter == _sentinel ? this.filter : filter as EventType?,
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fmtTime(DateTime t) {
  final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
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
    return HomeState(
      events:    ref.read(homeServiceProvider).getEvents(),
      userRsvps: const {},
    );
  }

  /// Toggle RSVP: tapping the same option again deselects it.
  void toggleRsvp(String eventId, HomeRsvp rsvp) {
    final current = state.userRsvps[eventId] ?? HomeRsvp.none;
    final next    = current == rsvp ? HomeRsvp.none : rsvp;

    state = state.copyWith(
      userRsvps: {...state.userRsvps, eventId: next},
    );
  }

  void setFilter(EventType? f) => state = state.copyWith(filter: f);
}

// ─── Providers ────────────────────────────────────────────────────────────────

final homeServiceProvider =
    Provider<HomeService>((ref) => HomeService());

final homeProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
