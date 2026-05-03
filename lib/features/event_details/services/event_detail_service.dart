import '../models/event_detail_model.dart';
import '../models/event_player_model.dart';

class EventDetailService {
  EventDetailModel getEventDetail(String eventId) {
    // TODO: fetch by eventId when backend is ready
    return const EventDetailModel(
      id:              '1',
      name:            'Practice',
      date:            'Monday, March 23, 2026',
      timeRange:       '6:00 PM \u2013 7:30 PM',
      locationName:    'Gillis-Rother Soccer Complex - Field 12',
      locationAddress: '1001 E Robinson St, Norman, OK 73071',
      uniform:         'White / Green',
      homeAway:        'Home',
      opponent:        'OKC Energy FC',
      arrivalTime:     '12:15 PM',
      myRsvp:          'no',
    );
  }

  List<EventPlayerModel> getEventPlayers(String eventId) {
    // TODO: fetch by eventId when backend is ready
    return const [
      EventPlayerModel(id: 1, name: 'Kinsley Weston',   number: '1',  status: PlayerStatus.going, note: ''),
      EventPlayerModel(id: 2, name: 'Kinley Kirkes',    number: '5',  status: PlayerStatus.going, note: ''),
      EventPlayerModel(id: 3, name: 'Mila Chaisson',    number: '10', status: PlayerStatus.going, note: ''),
      EventPlayerModel(id: 4, name: 'Scarlett Garling', number: '12', status: PlayerStatus.going, note: 'Running 5 mins late'),
      EventPlayerModel(id: 5, name: 'Nene Randolph',    number: '61', status: PlayerStatus.going, note: ''),
      EventPlayerModel(id: 6, name: 'Rose Hall',        number: '11', status: PlayerStatus.none,  note: ''),
      EventPlayerModel(id: 7, name: 'Emma Smith',       number: '4',  status: PlayerStatus.none,  note: ''),
    ];
  }
}
