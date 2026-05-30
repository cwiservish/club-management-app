import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/club_event.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../home/providers/home_provider.dart';
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
  final List<EventPlayerModel> players;
  final bool isLoading;
  final String? errorMessage;
  final bool canUpdateAllPlayers;

  const EventDetailState({
    required this.event,
    required this.players,
    this.isLoading = false,
    this.errorMessage,
    this.canUpdateAllPlayers = false,
  });

  EventDetailState copyWith({
    EventDetailModel? event,
    List<EventPlayerModel>? players,
    bool? isLoading,
    String? errorMessage,
    bool? canUpdateAllPlayers,
  }) {
    return EventDetailState(
      event:   event   ?? this.event,
      players: players ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == null ? this.errorMessage : (errorMessage.isEmpty ? null : errorMessage),
      canUpdateAllPlayers: canUpdateAllPlayers ?? this.canUpdateAllPlayers,
    );
  }

  List<EventPlayerModel> get goingPlayers     => players.where((p) => p.status == PlayerStatus.going).toList();
  List<EventPlayerModel> get maybePlayers     => players.where((p) => p.status == PlayerStatus.maybe).toList();
  List<EventPlayerModel> get noPlayers        => players.where((p) => p.status == PlayerStatus.no).toList();
  List<EventPlayerModel> get unrepliedPlayers => players.where((p) => p.status == PlayerStatus.none).toList();
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class EventDetailNotifier extends Notifier<EventDetailState> {
  final String eventId;
  EventDetailNotifier(this.eventId);

  int? _teamEventId;

  @override
  EventDetailState build() {
    final service = ref.read(eventDetailServiceProvider);
    final activeTeam = ref.watch(selectedTeamProvider);
    final homeState = ref.watch(homeProvider);

    ClubEvent? foundEvent;
    for (final e in homeState.events) {
      if (e.id == eventId) {
        foundEvent = e;
        break;
      }
    }

    final EventDetailModel eventDetail;
    if (foundEvent != null) {
      String userRsvp = '';
      if (foundEvent.rsvpYes.contains('me')) {
        userRsvp = 'going';
      } else if (foundEvent.rsvpMaybe.contains('me')) {
        userRsvp = 'maybe';
      } else if (foundEvent.rsvpNo.contains('me')) {
        userRsvp = 'no';
      }

      final dateStr = _fmtDate(foundEvent.dateTime);
      final timeRangeStr = '${_fmtTime(foundEvent.dateTime)} - ${_fmtTime(foundEvent.endTime)}';

      eventDetail = EventDetailModel(
        id: foundEvent.id,
        name: foundEvent.title,
        date: dateStr,
        timeRange: timeRangeStr,
        locationName: foundEvent.location,
        locationAddress: (foundEvent.locationDetails != null && foundEvent.locationDetails!.isNotEmpty)
            ? foundEvent.locationDetails!
            : foundEvent.subtitle,
        uniform: foundEvent.uniformColor ?? '',
        homeAway: 'Home',
        opponent: foundEvent.opponent ?? '',
        arrivalTime: foundEvent.arrivalTime ?? '',
        myRsvp: userRsvp,
      );

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
      players: activeTeam != null ? [] : service.getEventPlayers(eventId),
      isLoading: activeTeam != null,
      canUpdateAllPlayers: true,
    );
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
    state = state.copyWith(isLoading: true, errorMessage: '', players: []);
    try {
      final service = ref.read(eventDetailServiceProvider);
      final response = await service.fetchEventAvailability(
        EventAvailabilityRequest(
          teamUuid: teamUuid,
          eventUuid: eventId,
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
          canUpdateAllPlayers: response.data!.canUpdateAllPlayers,
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

    final int targetPlayerId = player.playerId ?? player.id;
    final int eventDbId = _teamEventId ?? int.tryParse(eventId) ?? 0;

    final String finalCustomerId = '';
    final int finalPlayerId = targetPlayerId;

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
          teamEventId: eventDbId,
          customerId: finalCustomerId,
          playerId: finalPlayerId,
          notes: player.note,
          attendance: attendanceValue,
        ),
      );

      if (response.success) {
        // Refresh availability to get latest server state
        await refresh();
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

    final int targetPlayerId = player.playerId ?? player.id;
    final int eventDbId = _teamEventId ?? int.tryParse(eventId) ?? 0;

    final String finalCustomerId = '';
    final int finalPlayerId = targetPlayerId;

    try {
      final service = ref.read(eventDetailServiceProvider);
      final response = await service.saveEventAttendee(
        EventAttendeeSaveRequest(
          teamUuid: activeTeam.uuid,
          teamEventId: eventDbId,
          customerId: finalCustomerId,
          playerId: finalPlayerId,
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
    NotifierProvider.family<EventDetailNotifier, EventDetailState, String>(
  EventDetailNotifier.new,
);
