// ─── Event Player Model ────────────────────────────────────────────────────────

enum PlayerStatus { going, maybe, no, none }

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

  EventPlayerModel copyWith({
    PlayerStatus? status,
    String? note,
  }) {
    return EventPlayerModel(
      id: id,
      name: name,
      number: number,
      imageUrl: imageUrl,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}

// ─── Dummy players ─────────────────────────────────────────────────────────────

final List<EventPlayerModel> sampleEventPlayers = [
  const EventPlayerModel(id: 1, name: 'Kinsley Weston',  number: '1',  status: PlayerStatus.going, note: ''),
  const EventPlayerModel(id: 2, name: 'Kinley Kirkes',   number: '5',  status: PlayerStatus.going, note: ''),
  const EventPlayerModel(id: 3, name: 'Mila Chaisson',   number: '10', status: PlayerStatus.going, note: ''),
  const EventPlayerModel(id: 4, name: 'Scarlett Garling',number: '12', status: PlayerStatus.going, note: 'Running 5 mins late'),
  const EventPlayerModel(id: 5, name: 'Nene Randolph',   number: '61', status: PlayerStatus.going, note: ''),
  const EventPlayerModel(id: 6, name: 'Rose Hall',       number: '11', status: PlayerStatus.none,  note: ''),
  const EventPlayerModel(id: 7, name: 'Emma Smith',      number: '4',  status: PlayerStatus.none,  note: ''),
];
