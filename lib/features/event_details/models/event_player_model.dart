// ─── Player Status ────────────────────────────────────────────────────────────

enum PlayerStatus { going, maybe, no, none }

// ─── Event Player Model ───────────────────────────────────────────────────────

class EventPlayerModel {
  final int id;
  final int? playerId;
  final String name;
  final String number;
  final String? imageUrl;
  final PlayerStatus status;
  final String note;
  final bool canUpdate;

  const EventPlayerModel({
    required this.id,
    this.playerId,
    required this.name,
    required this.number,
    this.imageUrl,
    required this.status,
    required this.note,
    this.canUpdate = true,
  });

  bool get hasNote => note.isNotEmpty;

  EventPlayerModel copyWith({PlayerStatus? status, String? note, bool? canUpdate}) {
    return EventPlayerModel(
      id:       id,
      playerId: playerId,
      name:     name,
      number:   number,
      imageUrl: imageUrl,
      status:   status ?? this.status,
      note:     note ?? this.note,
      canUpdate: canUpdate ?? this.canUpdate,
    );
  }
}
