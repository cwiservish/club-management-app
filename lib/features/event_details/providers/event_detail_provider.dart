import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/club_event.dart';
import '../../../core/enums/event_type.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/common_providers/event_refresh_provider.dart';
import '../models/event_detail_model.dart';
import '../models/event_player_model.dart';
import '../models/event_availability_models.dart';
import '../services/event_detail_service.dart';

export '../models/event_detail_model.dart';
export '../models/event_player_model.dart';
export '../models/event_availability_models.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class EventDetailState {
  final EventDetailModel event;
  final ClubEvent? rawEvent;
  final List<EventPlayerModel> players;
  final bool isLoading;
  final String? errorMessage;

  const EventDetailState({
    required this.event,
    this.rawEvent,
    required this.players,
    this.isLoading = false,
    this.errorMessage,
  });

  EventDetailState copyWith({
    EventDetailModel? event,
    ClubEvent? rawEvent,
    List<EventPlayerModel>? players,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EventDetailState(
      event:    event    ?? this.event,
      rawEvent: rawEvent ?? this.rawEvent,
      players:  players  ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == null ? this.errorMessage : (errorMessage.isEmpty ? null : errorMessage),
    );
  }

  // Once availability is loaded, derive counts directly from the live player list
  // so optimistic updates to player statuses are immediately reflected.
  // Before availability loads, fall back to the rawEvent snapshot + adjustment
  // for the current user's own RSVP (mirrors the home page logic exactly).
  int get goingCount {
    if (players.isNotEmpty) {
      return goingPlayers.length + (event.myRsvp == 'going' ? 1 : 0);
    }
    final base     = rawEvent?.rsvpYes.length ?? 0;
    final hadGoing = rawEvent?.rsvpYes.contains('me') ?? false;
    if (event.myRsvp == 'going' && !hadGoing) return base + 1;
    if (hadGoing && event.myRsvp != 'going')  return base - 1;
    return base;
  }

  int get maybeCount {
    if (players.isNotEmpty) {
      return maybePlayers.length + (event.myRsvp == 'maybe' ? 1 : 0);
    }
    final base     = rawEvent?.rsvpMaybe.length ?? 0;
    final hadMaybe = rawEvent?.rsvpMaybe.contains('me') ?? false;
    if (event.myRsvp == 'maybe' && !hadMaybe) return base + 1;
    if (hadMaybe && event.myRsvp != 'maybe')  return base - 1;
    return base;
  }

  int get noCount {
    if (players.isNotEmpty) {
      return noPlayers.length + (event.myRsvp == 'no' ? 1 : 0);
    }
    final base  = rawEvent?.rsvpNo.length ?? 0;
    final hadNo = rawEvent?.rsvpNo.contains('me') ?? false;
    if (event.myRsvp == 'no' && !hadNo) return base + 1;
    if (hadNo && event.myRsvp != 'no')  return base - 1;
    return base;
  }

  List<EventPlayerModel> get goingPlayers     => players.where((p) => p.status == PlayerStatus.going).toList();
  List<EventPlayerModel> get maybePlayers     => players.where((p) => p.status == PlayerStatus.maybe).toList();
  List<EventPlayerModel> get noPlayers        => players.where((p) => p.status == PlayerStatus.no).toList();
  List<EventPlayerModel> get unrepliedPlayers => players.where((p) => p.status == PlayerStatus.none).toList();
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class EventDetailNotifier extends Notifier<EventDetailState> {
  final EventDetailArgs _args;
  EventDetailNotifier(this._args);

  String get eventId => _args.eventId;

  int? _teamEventId;

  @override
  EventDetailState build() {
    final service = ref.read(eventDetailServiceProvider);
    final activeTeam = ref.watch(selectedTeamProvider);

    final ClubEvent? foundEvent = _args.event;

    final EventDetailModel eventDetail;
    if (foundEvent != null) {
      eventDetail = _buildEventDetail(foundEvent);
      _teamEventId = foundEvent.dbId;
    } else {
      eventDetail = service.getEventDetail(eventId);
    }

    // Fetch reactively when team changes
    if (activeTeam != null) {
      Future.microtask(() => fetchAvailability(activeTeam.uuid));
    }

    return EventDetailState(
      event:   eventDetail,
      rawEvent: foundEvent,
      players: activeTeam != null ? [] : service.getEventPlayers(eventId),
      isLoading: activeTeam != null,
    );
  }

  EventDetailModel _buildEventDetail(ClubEvent event) {
    String userRsvp = '';
    if (event.rsvpYes.contains('me')) userRsvp = 'going';
    else if (event.rsvpMaybe.contains('me')) userRsvp = 'maybe';
    else if (event.rsvpNo.contains('me')) userRsvp = 'no';

    final dateStr = (event.dateLabel != null && event.dateLabel!.isNotEmpty)
        ? event.dateLabel!
        : _fmtDate(event.dateTime);
    final timeRangeStr = (event.timeLabel != null && event.timeLabel!.isNotEmpty)
        ? event.timeLabel!
        : '${_fmtTime(event.dateTime)} - ${_fmtTime(event.endTime)}';

    return EventDetailModel(
      id: event.id,
      name: event.title,
      date: dateStr,
      timeRange: timeRangeStr,
      locationName: event.location,
      locationAddress: (event.locationDetails != null && event.locationDetails!.isNotEmpty)
          ? event.locationDetails!
          : event.subtitle,
      latitude: event.latitude,
      longitude: event.longitude,
      uniform: event.uniformColor ?? '',
      uniformTopColor: event.uniformTopColor,
      uniformBottomColor: event.uniformBottomColor,
      uniformSocksColor: event.uniformSocksColor,
      isGame: event.type == EventType.game,
      homeAway: (event.homeAwayLabel != null && event.homeAwayLabel!.isNotEmpty)
          ? event.homeAwayLabel!
          : _homeAwayLabel(event.homeAwayKey),
      opponent: event.opponent ?? '',
      arrivalTime: (event.arrivalTime != null && event.arrivalTime!.isNotEmpty)
          ? event.arrivalTime!
          : _arrivalLabel(event.arrivalEarly),
      myRsvp: userRsvp,
    );
  }

  String _homeAwayLabel(int key) {
    switch (key) {
      case 1: return 'Home';
      case 2: return 'Away';
      case 3: return 'Neutral';
      default: return '-';
    }
  }

  String _arrivalLabel(int minutes) {
    if (minutes == 0) return 'No arrival time set';
    return '$minutes min early';
  }

  String _fmtTime(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final hStr = h.toString().padLeft(2, '0');
    final mStr = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hStr : $mStr $period';
  }

  String _fmtDate(DateTime dt) {
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dayName = daysOfWeek[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, $monthName ${dt.day}, ${dt.year}';
  }

  /// Asynchronously fetches availability from the API
  Future<void> fetchAvailability(String teamUuid) async {
    // Only show loader on the very first fetch — subsequent refreshes update in place
    final isInitialLoad = state.players.isEmpty;
    if (isInitialLoad) {
      state = state.copyWith(isLoading: true, errorMessage: '');
    }
    try {
      final service = ref.read(eventDetailServiceProvider);
      final sessionId = _teamEventId ?? int.tryParse(eventId) ?? 0;
      final response = await service.fetchEventAvailability(
        EventAvailabilityRequest(
          teamUuid: teamUuid,
          id: sessionId,
        ),
      );

      if (response.success && response.data != null) {
        if (response.data!.event != null) {
          _teamEventId = response.data!.event!.teamEventId;
        }

        final List<EventPlayerModel> mappedPlayers = [];

        for (final group in response.data!.groups) {
          final status = _mapGroupKeyToStatus(group.key);
          for (final player in group.players) {
            mappedPlayers.add(
              EventPlayerModel(
                id: player.teamPlayerId,
                playerId: player.playerId,
                name: player.name,
                number: player.jerseyNo.isNotEmpty ? player.jerseyNo : 'N/A',
                imageUrl: player.imageUrl.isNotEmpty ? player.imageUrl : (player.profileImageUrl.isNotEmpty ? player.profileImageUrl : null),
                status: status,
                note: player.notes,
                canUpdate: player.canUpdate,
              ),
            );
          }
        }
        state = state.copyWith(
          players: mappedPlayers,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message.isNotEmpty ? response.message : 'Failed to load availability.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  PlayerStatus _mapGroupKeyToStatus(String key) {
    switch (key.toLowerCase()) {
      case 'going':
        return PlayerStatus.going;
      case 'maybe':
        return PlayerStatus.maybe;
      case 'not_going':
        return PlayerStatus.no;
      case 'not_replied':
      default:
        return PlayerStatus.none;
    }
  }

  /// Triggers availability API refresh
  Future<void> refresh() async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam != null) {
      await fetchAvailability(activeTeam.uuid);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void setRsvp(String rsvp) {
    state = state.copyWith(event: state.event.copyWith(myRsvp: rsvp));
  }

  /// Updates rawEvent with a fresh ClubEvent snapshot (e.g. after navigating
  /// back from home where the user changed their RSVP). Also re-derives myRsvp
  /// from the fresh snapshot so counts stay consistent with the home page.
  void syncRawEvent(ClubEvent? event) {
    if (event == null) return;
    _teamEventId = event.dbId;
    state = state.copyWith(
      rawEvent: event,
      event: _buildEventDetail(event),
    );
  }

  /// Asynchronously saves RSVP status on the server and refreshes availability + home/schedule lists.
  Future<({bool success, String message})> saveEventRsvp({
    required ClubEventRsvpTarget target,
    required String rsvp, // 'going', 'maybe', 'no'
  }) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      return (success: false, message: 'No selected team found');
    }

    final eventDbId = _teamEventId ?? int.tryParse(eventId) ?? 0;

    int attendanceValue = 0;
    if (rsvp == 'going') attendanceValue = 1;
    if (rsvp == 'maybe') attendanceValue = 2;
    if (rsvp == 'no') attendanceValue = 0;

    // Optimistic update — instant UI response
    final previousRsvp = state.event.myRsvp;
    setRsvp(rsvp);

    try {
      final service = ref.read(eventDetailServiceProvider);
      final response = await service.saveEventAttendee(
        EventAttendeeSaveRequest(
          teamUuid: activeTeam.uuid,
          teamEventSessionId: eventDbId,
          attendeeType: target.attendeeType,
          attendeeId: target.customerId,
          notes: target.notes,
          attendance: attendanceValue,
        ),
      );

      if (response.success) {
        // Background refresh — no loader, players not cleared
        refresh();
        ref.read(eventRefreshSignalProvider.notifier).signal();
        return (success: true, message: response.message.isNotEmpty ? response.message : 'RSVP updated successfully.');
      } else {
        // Revert optimistic update
        setRsvp(previousRsvp);
        return (success: false, message: response.message.isNotEmpty ? response.message : 'Failed to update RSVP.');
      }
    } catch (e) {
      // Revert optimistic update
      setRsvp(previousRsvp);
      return (success: false, message: e.toString());
    }
  }

  /// Asynchronously saves a player's RSVP status via the event-attendee save API
  /// and then refreshes the availability list.
  Future<({bool success, String message})> updatePlayerStatus(int teamPlayerId, PlayerStatus status) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      return (success: false, message: 'No selected team found');
    }

    EventPlayerModel? player;
    for (final p in state.players) {
      if (p.id == teamPlayerId) {
        player = p;
        break;
      }
    }

    if (player == null) {
      return (success: false, message: 'Player not found');
    }

    final int eventDbId = _teamEventId ?? int.tryParse(eventId) ?? 0;

    // Map status to attendance integer: going=1, maybe=2, no=0
    int attendanceValue = 0;
    if (status == PlayerStatus.going) attendanceValue = 1;
    if (status == PlayerStatus.maybe) attendanceValue = 2;
    if (status == PlayerStatus.no) attendanceValue = 0;

    // Optimistically update local state
    state = state.copyWith(
      players: state.players
          .map((p) => p.id == teamPlayerId ? p.copyWith(status: status) : p)
          .toList(),
    );

    try {
      final service = ref.read(eventDetailServiceProvider);
      final response = await service.saveEventAttendee(
        EventAttendeeSaveRequest(
          teamUuid: activeTeam.uuid,
          teamEventSessionId: eventDbId,
          attendeeType: 'player',
          attendeeId: player.playerId ?? player.id,
          notes: player.note,
          attendance: attendanceValue,
        ),
      );

      if (response.success) {
        // Optimistic state is already correct — no refresh needed.
        // Signal home to update its counts in the background.
        ref.read(eventRefreshSignalProvider.notifier).signal();
        return (success: true, message: response.message.isNotEmpty ? response.message : 'Status updated successfully.');
      } else {
        // Revert optimistic update on failure
        state = state.copyWith(
          players: state.players
              .map((p) => p.id == teamPlayerId ? p.copyWith(status: player!.status) : p)
              .toList(),
        );
        return (success: false, message: response.message.isNotEmpty ? response.message : 'Failed to update status.');
      }
    } catch (e) {
      // Revert optimistic update on error
      state = state.copyWith(
        players: state.players
            .map((p) => p.id == teamPlayerId ? p.copyWith(status: player!.status) : p)
            .toList(),
      );
      return (success: false, message: e.toString());
    }
  }

  /// Asynchronously saves the player note using the event-attendee save API
  Future<({bool success, String message})> updatePlayerNote(int teamPlayerId, String note) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      return (success: false, message: 'No selected team found');
    }

    EventPlayerModel? player;
    for (final p in state.players) {
      if (p.id == teamPlayerId) {
        player = p;
        break;
      }
    }

    if (player == null) {
      return (success: false, message: 'Player not found');
    }

    final int eventDbId = _teamEventId ?? int.tryParse(eventId) ?? 0;

    try {
      final service = ref.read(eventDetailServiceProvider);
      final response = await service.saveEventAttendee(
        EventAttendeeSaveRequest(
          teamUuid: activeTeam.uuid,
          teamEventSessionId: eventDbId,
          attendeeType: 'player',
          attendeeId: player.playerId ?? player.id,
          notes: note,
        ),
      );

      if (response.success) {
        state = state.copyWith(
          players: state.players
              .map((p) => p.id == teamPlayerId ? p.copyWith(note: note) : p)
              .toList(),
        );
        return (success: true, message: response.message.isNotEmpty ? response.message : 'Attendee saved successfully.');
      } else {
        return (success: false, message: response.message.isNotEmpty ? response.message : 'Failed to save attendee.');
      }
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final eventDetailProvider =
    NotifierProvider.family<EventDetailNotifier, EventDetailState, EventDetailArgs>(
  EventDetailNotifier.new,
);
