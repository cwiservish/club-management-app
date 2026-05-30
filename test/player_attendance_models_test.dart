// ignore_for_file: depend_on_referenced_packages
import 'package:test/test.dart';
import 'package:playbook365/features/roster/models/player_attendance_models.dart';

void main() {
  group('Player Attendance History Models Tests', () {
    test('PlayerAttendanceEvent parses full JSON safely', () {
      final json = {
        'id': 12,
        'team_event_id': 34,
        'uuid': 'evt-uuid-123',
        'schedule_game_id': 56,
        'event_name': 'Championship Game',
        'event_date': '2026-05-30',
        'date_label': 'May 30, 2026',
        'start_time': '16:00:00',
        'end_time': '18:00:00',
        'time_label': '4:00 PM',
        'location': 'Main Field',
        'location_details': 'Field 3',
        'opponant': 'Thunder FC', // Test handling backend typo
        'extra_label': 'Important Game',
        'team_event_attendee_id': 99,
        'attendance': 1,
        'attendance_notes': 'Arriving early',
      };

      final event = PlayerAttendanceEvent.fromJson(json);
      expect(event.id, 12);
      expect(event.teamEventId, 34);
      expect(event.uuid, 'evt-uuid-123');
      expect(event.scheduleGameId, 56);
      expect(event.eventName, 'Championship Game');
      expect(event.opponent, 'Thunder FC');
      expect(event.attendance, 1);
      expect(event.attendanceNotes, 'Arriving early');
    });

    test('PlayerAttendanceEvent handles standard opponent spelling', () {
      final json = {
        'id': 12,
        'team_event_id': 34,
        'uuid': 'evt-uuid-123',
        'event_name': 'Championship Game',
        'event_date': '2026-05-30',
        'date_label': 'May 30, 2026',
        'start_time': '16:00:00',
        'end_time': '18:00:00',
        'time_label': '4:00 PM',
        'location': 'Main Field',
        'location_details': 'Field 3',
        'opponent': 'Thunder FC', // Standard spelling
        'attendance_notes': '',
      };

      final event = PlayerAttendanceEvent.fromJson(json);
      expect(event.opponent, 'Thunder FC');
    });

    test('PlayerAttendanceEvent parses missing and null fields defensively', () {
      final json = <String, dynamic>{};
      final event = PlayerAttendanceEvent.fromJson(json);
      expect(event.id, 0);
      expect(event.teamEventId, 0);
      expect(event.uuid, '');
      expect(event.eventName, '');
      expect(event.opponent, isNull);
      expect(event.attendance, isNull);
      expect(event.attendanceNotes, '');
    });

    test('PlayerAttendanceHistoryResponse parses full response structure safely', () {
      final responseJson = {
        'success': true,
        'message': 'Success',
        'data': {
          'grid': [
            {
              'id': 12,
              'team_event_id': 34,
              'uuid': 'evt-uuid-123',
              'event_name': 'Practice',
              'event_date': '2026-05-30',
              'date_label': 'May 30, 2026',
              'start_time': '16:00:00',
              'end_time': '18:00:00',
              'time_label': '4:00 PM',
              'location': 'Main Field',
              'location_details': 'Field 3',
              'attendance': 2,
              'attendance_notes': '',
            }
          ],
          'total': 1
        }
      };

      final response = PlayerAttendanceHistoryResponse.fromJson(responseJson);
      expect(response.success, true);
      expect(response.message, 'Success');
      expect(response.data, isNotNull);
      expect(response.data!.total, 1);
      expect(response.data!.grid, isNotEmpty);
      expect(response.data!.grid[0].eventName, 'Practice');
      expect(response.data!.grid[0].attendance, 2);
    });

    test('PlayerAttendanceHistoryResponse handles invalid or missing data defensively', () {
      final responseJson = {
        'success': false,
        'message': 'Error loading history',
      };

      final response = PlayerAttendanceHistoryResponse.fromJson(responseJson);
      expect(response.success, false);
      expect(response.message, 'Error loading history');
      expect(response.data, isNull);
    });
  });
}
