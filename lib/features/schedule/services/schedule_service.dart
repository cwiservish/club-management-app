import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/models/club_event.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/schedule_response.dart';

class ScheduleService {
  final ApiClient _apiClient;

  ScheduleService(this._apiClient);

  /// Fetch all schedule events grouped by month for a specific team.
  Future<List<ClubEvent>> fetchScheduleEvents(String teamUuid) async {
    const endpoint = ApiEndpoints.teamEventsAll;
    final queryParameters = {
      'team_uuid': teamUuid,
      'formate': 'month-wise',
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint(const JsonEncoder.withIndent('  ').convert(queryParameters));
    debugPrint('════════════════════════════════════════════════════════════════');

    try {
      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final rawResponseMap = {
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data,
      };

      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
      debugPrint('════════════════════════════════════════════════════════════════');

      if (!response.success || response.data == null) {
        return [];
      }

      final parsedResponse = ScheduleAllEventsResponse.fromJson(rawResponseMap);
      if (parsedResponse.data == null) {
        return [];
      }

      final List<ClubEvent> events = [];
      for (final month in parsedResponse.data!.months) {
        for (final event in month.events) {
          events.add(event.toDomain());
        }
      }

      return events;
    } catch (e, stackTrace) {
      debugPrint('[ScheduleService] Error fetching schedule events: $e');
      debugPrint(stackTrace.toString());
      return [];
    }
  }

  Future<({bool success, String message})> saveEventRsvp({
    required String teamUuid,
    required int teamEventSessionId,
    required ClubEventRsvpTarget target,
    required int attendance,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.eventSessionAttendeeSave,
        body: {
          'team_uuid': teamUuid,
          'team_event_session_id': teamEventSessionId,
          'attendee_type': target.attendeeType,
          'attendee_id': target.customerId,
          'notes': target.notes,
          'attendance': attendance,
        },
      );
      return (success: response.success, message: response.message ?? '');
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }
}
