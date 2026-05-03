// ─── Player Status ────────────────────────────────────────────────────────────

enum PlayerStatus { going, maybe, no, none }

// ─── Event Player Model ───────────────────────────────────────────────────────

class EventPlayerModel {
  final int id;
  final String name;
  final String number;
  final String? imageUrl;
  final PlayerStatus status;
  final String note;

  const EventPlayerModel({
    required this.id,
    required this.name,
    required this.number,
    this.imageUrl,
    required this.status,
    required this.note,
  });

  bool get hasNote => note.isNotEmpty;

  EventPlayerModel copyWith({PlayerStatus? status, String? note}) {
    return EventPlayerModel(
      id:       id,
      name:     name,
      number:   number,
      imageUrl: imageUrl,
      status:   status ?? this.status,
      note:     note ?? this.note,
    );
  }
}
