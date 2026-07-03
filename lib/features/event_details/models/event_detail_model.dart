import '../../../core/models/club_event.dart';

// ─── Event Detail Args ────────────────────────────────────────────────────────
// Carrier for the family provider key. Equality is based on eventId only so
// that tab switching (which passes null event) reuses the same provider instance.

class EventDetailArgs {
  final String eventId;
  final ClubEvent? event;

  const EventDetailArgs(this.eventId, [this.event]);

  @override
  bool operator ==(Object other) =>
      other is EventDetailArgs && other.eventId == eventId;

  @override
  int get hashCode => eventId.hashCode;
}

// ─── Event Detail Model ────────────────────────────────────────────────────────

class EventDetailModel {
  final String id;
  final String name;
  final String date;        // e.g. "Monday, March 23, 2026"
  final String timeRange;   // e.g. "6:00 PM – 7:30 PM"
  final String locationName;
  final String locationAddress;
  final String? latitude;
  final String? longitude;
  final String uniform;
  final String uniformTopColor;    // hex string, empty = no color
  final String uniformBottomColor;
  final String uniformSocksColor;
  final bool isGame;               // true for game/scrimmage — controls home/away + opponent visibility
  final String homeAway;           // "Home" | "Away" | "Neutral" | "-"
  final String opponent;
  final String arrivalTime;        // human-readable label
  final String myRsvp;             // 'going' | 'maybe' | 'no'

  const EventDetailModel({
    required this.id,
    required this.name,
    required this.date,
    required this.timeRange,
    required this.locationName,
    required this.locationAddress,
    this.latitude,
    this.longitude,
    required this.uniform,
    this.uniformTopColor = '',
    this.uniformBottomColor = '',
    this.uniformSocksColor = '',
    this.isGame = false,
    required this.homeAway,
    required this.opponent,
    required this.arrivalTime,
    required this.myRsvp,
  });

  EventDetailModel copyWith({String? myRsvp}) {
    return EventDetailModel(
      id:                  id,
      name:                name,
      date:                date,
      timeRange:           timeRange,
      locationName:        locationName,
      locationAddress:     locationAddress,
      latitude:            latitude,
      longitude:           longitude,
      uniform:             uniform,
      uniformTopColor:     uniformTopColor,
      uniformBottomColor:  uniformBottomColor,
      uniformSocksColor:   uniformSocksColor,
      isGame:              isGame,
      homeAway:            homeAway,
      opponent:            opponent,
      arrivalTime:         arrivalTime,
      myRsvp:              myRsvp ?? this.myRsvp,
    );
  }
}

// ─── Tab enum ─────────────────────────────────────────────────────────────────

enum EventDetailTab { details, availability }
