import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_detail_model.dart';
import '../models/event_player_model.dart';
import '../services/event_detail_service.dart';

export '../models/event_detail_model.dart';
export '../models/event_player_model.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class EventDetailState {
  final EventDetailModel event;
  final List<EventPlayerModel> players;

  const EventDetailState({
    required this.event,
    required this.players,
  });

  EventDetailState copyWith({
    EventDetailModel? event,
    List<EventPlayerModel>? players,
  }) {
    return EventDetailState(
      event:   event   ?? this.event,
      players: players ?? this.players,
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

  @override
  EventDetailState build() {
    final service = ref.read(eventDetailServiceProvider);
    return EventDetailState(
      event:   service.getEventDetail(eventId),
      players: service.getEventPlayers(eventId),
    );
  }

  void setRsvp(String rsvp) {
    state = state.copyWith(event: state.event.copyWith(myRsvp: rsvp));
  }

  void updatePlayerStatus(int playerId, PlayerStatus status) {
    state = state.copyWith(
      players: state.players
          .map((p) => p.id == playerId ? p.copyWith(status: status) : p)
          .toList(),
    );
  }

  void updatePlayerNote(int playerId, String note) {
    state = state.copyWith(
      players: state.players
          .map((p) => p.id == playerId ? p.copyWith(note: note) : p)
          .toList(),
    );
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final eventDetailServiceProvider =
    Provider<EventDetailService>((ref) => EventDetailService());

final eventDetailProvider =
    NotifierProvider.family<EventDetailNotifier, EventDetailState, String>(
  EventDetailNotifier.new,
);
