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
  final String homeAway;
  final String opponent;
  final String arrivalTime;
  final String myRsvp;      // 'going' | 'maybe' | 'no'

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
    required this.homeAway,
    required this.opponent,
    required this.arrivalTime,
    required this.myRsvp,
  });

  EventDetailModel copyWith({String? myRsvp}) {
    return EventDetailModel(
      id:              id,
      name:            name,
      date:            date,
      timeRange:       timeRange,
      locationName:    locationName,
      locationAddress: locationAddress,
      latitude:        latitude,
      longitude:       longitude,
      uniform:         uniform,
      homeAway:        homeAway,
      opponent:        opponent,
      arrivalTime:     arrivalTime,
      myRsvp:          myRsvp ?? this.myRsvp,
    );
  }
}

// ─── Tab enum ─────────────────────────────────────────────────────────────────

enum EventDetailTab { details, availability }
