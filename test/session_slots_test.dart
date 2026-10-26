import 'package:flutter_test/flutter_test.dart';
import 'package:playbook365/features/event_details/models/event_delete_models.dart';
import 'package:playbook365/features/event_details/models/new_event_save_request_model.dart';
import 'package:playbook365/features/event_details/models/session_slot_models.dart';

void main() {
  group('SlotBoard.fromJson', () {
    final json = {
      'checked': true,
      'has_conflicts': true,
      'conflict_count': 1,
      'exclude_ids': [7],
      'slots': [
        {
          'date': '2026-11-03', 'start_time': '17:00', 'end_time': '18:30',
          'location_type': 1, 'venue_id': 4, 'field_id': 21,
          'checked': true, 'is_available': true, 'is_blocking': false,
          'warnings': [], 'message': 'The space is available.',
        },
        {
          'date': '2026-11-05', 'start_time': '17:00', 'end_time': '18:30',
          'location_type': 1, 'venue_id': 4, 'field_id': 21,
          'checked': true, 'is_available': false, 'is_blocking': true,
          'warnings': ['The space has a club event.'], 'message': 'x',
        },
        {'date': '2026-11-10', 'start_time': '19:00', 'end_time': '20:30', 'field_id': 22, 'locked': true,
         'locked_label': 'Edited separately'},
      ],
    };

    test('parses rows, conflict flags and exclude ids', () {
      final board = SlotBoard.fromJson(json);
      expect(board.slots.length, 3);
      expect(board.hasConflicts, isTrue);
      expect(board.conflictCount, 1);
      expect(board.excludeIds, [7]);
      expect(board.slots[0].isBlocking, isFalse);
      expect(board.slots[1].isBlocking, isTrue);
      expect(board.slots[1].warnings.single, 'The space has a club event.');
      expect(board.slots[2].locked, isTrue);
    });

    test('toSaveJson only carries date, times and field', () {
      final slot = SlotBoard.fromJson(json).slots.first;
      expect(slot.toSaveJson(), {
        'date': '2026-11-03', 'start_time': '17:00', 'end_time': '18:30', 'field_id': 21,
      });
    });

    test('copyWith keeps date and replaces availability', () {
      final slot = SlotBoard.fromJson(json).slots[1];
      final fixed = slot.copyWith(fieldId: 22, isBlocking: false, isAvailable: true, warnings: const []);
      expect(fixed.date, slot.date);
      expect(fixed.fieldId, 22);
      expect(fixed.isBlocking, isFalse);
    });

    test('derives conflicts when the server omits the summary keys', () {
      final board = SlotBoard.fromJson({'slots': (json['slots'] as List).sublist(0, 2)});
      expect(board.hasConflicts, isTrue);
      expect(board.conflictCount, 1);
    });
  });

  group('NewEventSaveResponse', () {
    test('detects a draft (status 5) and reads conflicts', () {
      final draft = NewEventSaveResponse.fromJson({
        'success': true, 'message': 'ok', 'data': {'status': 5},
      });
      expect(draft.isDraft, isTrue);

      final clash = NewEventSaveResponse.fromJson({
        'success': false, 'message': 'No changes were saved.',
        'data': {'conflicts': [{'date': '2026-11-05', 'field_id': 21}]},
      });
      expect(clash.success, isFalse);
      expect(clash.conflicts.single['date'], '2026-11-05');
    });
  });

  group('request shapes', () {
    NewEventSaveRequest base() => NewEventSaveRequest(
          teamUuid: 't', schedulingMode: 1, eventType: 2, title: 'x', location: 'Fac',
          sessionStartDate: '2026-11-03', startTime: '17:00', duration: 90, homeAway: 1, arrivalEarly: 0,
        );

    test('slots and series code are only sent when set', () {
      final plain = base().toJson();
      expect(plain.containsKey('slots'), isFalse);
      expect(plain.containsKey('code'), isFalse);

      final req = base()
        ..slots = [{'date': '2026-11-03', 'start_time': '17:00', 'end_time': '18:30', 'field_id': 21}]
        ..code = 'ABC123';
      final json = req.toJson();
      expect((json['slots'] as List).length, 1);
      expect(json['code'], 'ABC123');
    });

    test('delete sends code for a series and id for one date', () {
      final one = EventDeleteRequest(teamUuid: 't', id: 5, schedulingMode: 1).toJson();
      expect(one['id'], 5);
      expect(one.containsKey('code'), isFalse);

      final series = EventDeleteRequest(teamUuid: 't', id: 5, schedulingMode: 1, code: 'ABC123').toJson();
      expect(series['code'], 'ABC123');
      expect(series.containsKey('id'), isFalse);
    });
  });
}
