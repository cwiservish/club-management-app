import 'package:flutter_test/flutter_test.dart';
import 'package:playbook365/features/schedule/models/schedule_response.dart';

Map<String, dynamic> _row(Map<String, dynamic> extra) => {
      'id': 7,
      'session_date': '2026-11-02',
      'start_time': '18:00:00',
      'end_time': '19:00:00',
      'event_type': 2,
      ...extra,
    };

void main() {
  test('uniform_details keep names; empty colour_label means swatch only', () {
    final e = ScheduleEvent.fromJson(_row({
      'uniform_details': [
        {'key': 'top', 'label': 'Top', 'color': '#20242A', 'color_label': 'Black'},
        {'key': 'belt', 'label': 'Belt', 'color': '#123456', 'color_label': ''},
      ],
    })).toDomain();
    expect(e.uniformDetails.length, 2);
    expect(e.uniformDetails.first.colorLabel, 'Black');
    expect(e.uniformDetails.last.colorLabel, isEmpty);
    expect(ScheduleEvent.fromJson(_row({'uniform_details': []})).toDomain().uniformDetails, isEmpty);
  });

  test('can_rsvp and rsvp_targets come from the row', () {
    final e = ScheduleEvent.fromJson(_row({
      'can_rsvp': false,
      'rsvp_targets': [
        {'attendee_type': 'player', 'attendee_id': 11, 'name': 'Kid A'},
        {'attendee_type': 'player', 'attendee_id': 12, 'name': 'Kid B'},
      ],
      'my_rsvp': {'requires_player_selection': true},
    })).toDomain();
    expect(e.canRsvp, isFalse);
    expect(e.rsvpTargets.map((t) => t.customerId), [11, 12]);
    expect(e.requiresPlayerSelection, isTrue);
  });

  test('missing flags keep the old behaviour', () {
    final e = ScheduleEvent.fromJson(_row({})).toDomain();
    expect(e.canRsvp, isTrue);
    expect(e.canChangeDate, isTrue);
    expect(e.canChangeRecurrence, isTrue);
  });
}
