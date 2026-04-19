// ─── Event Detail Model ────────────────────────────────────────────────────────

class EventDetailModel {
  final String id;
  final String name;
  final String date;      // e.g. "Monday, March 23, 2026"
  final String timeRange; // e.g. "6:00 PM – 7:30 PM"
  final String locationName;
  final String locationAddress;
  final String uniform;
  final String homeAway;
  final String opponent;
  final String arrivalTime;
  final String myRsvp;    // 'going' | 'maybe' | 'no'

  const EventDetailModel({
    required this.id,
    required this.name,
    required this.date,
    required this.timeRange,
    required this.locationName,
    required this.locationAddress,
    required this.uniform,
    required this.homeAway,
    required this.opponent,
    required this.arrivalTime,
    required this.myRsvp,
  });

  EventDetailModel copyWith({
    String? myRsvp,
  }) {
    return EventDetailModel(
      id: id,
      name: name,
      date: date,
      timeRange: timeRange,
      locationName: locationName,
      locationAddress: locationAddress,
      uniform: uniform,
      homeAway: homeAway,
      opponent: opponent,
      arrivalTime: arrivalTime,
      myRsvp: myRsvp ?? this.myRsvp,
    );
  }
}

// ─── Dummy data ────────────────────────────────────────────────────────────────

const EventDetailModel sampleEventDetail = EventDetailModel(
  id: '1',
  name: 'Practice',
  date: 'Monday, March 23, 2026',
  timeRange: '6:00 PM – 7:30 PM',
  locationName: 'Gillis-Rother Soccer Complex - Field 12',
  locationAddress: '1001 E Robinson St, Norman, OK 73071',
  uniform: 'White / Green',
  homeAway: 'Home',
  opponent: 'OKC Energy FC',
  arrivalTime: '12:15 PM',
  myRsvp: 'no',
);
