import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/models/club_event.dart';
import '../../../core/enums/event_type.dart';
import '../models/home_models.dart';

class HomeService {
  final ApiClient _apiClient;

  HomeService(this._apiClient);

  /// Fetch events list from the QA endpoint for a specific team.
  Future<List<ClubEvent>> fetchEvents(String teamUuid) async {
    const endpoint = ApiEndpoints.teamEventsList;
    final requestBody = {
      'team_uuid': teamUuid,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    try {
      final response = await _apiClient.post(
        endpoint,
        body: requestBody,
      );

      final rawResponseMap = {
        'success': response.success,
        'message': response.message ?? '',
        'data': response.data,
      };

      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Response] POST $endpoint');
      debugPrint('[API Response success]: ${response.success}');
      debugPrint('[API Response Body length]: ${response.data != null ? response.data.toString().length : 0}');
      debugPrint('════════════════════════════════════════════════════════════════');

      if (!response.success || response.data == null) {
        return [];
      }

      final dataMap = response.data as Map<String, dynamic>?;
      if (dataMap == null) return [];

      final grid = dataMap['grid'] as List?;
      if (grid == null) return [];

      final List<ClubEvent> events = [];
      for (final item in grid) {
        if (item is Map<String, dynamic>) {
          final event = _parseClubEvent(item);
          if (event != null) {
            events.add(event);
          }
        }
      }

      return events;
    } catch (e, stackTrace) {
      debugPrint('[HomeService] Error fetching events: $e');
      debugPrint(stackTrace.toString());
      return [];
    }
  }

  /// Crash-proof parser from QA JSON item to ClubEvent domain model.
  ClubEvent? _parseClubEvent(Map<String, dynamic> json) {
    try {
      final uuid = json['uuid']?.toString() ?? json['id']?.toString() ?? '';
      if (uuid.isEmpty) return null;

      final title = json['event_name']?.toString() ?? 'Event';
      final subtitle = json['extra_label']?.toString() ?? '';
      
      // Parse start_time / end_time safely
      final startTimeStr = json['start_time']?.toString() ?? json['event_date']?.toString() ?? '';
      DateTime dateTime;
      try {
        dateTime = DateTime.parse(startTimeStr);
      } catch (_) {
        dateTime = DateTime.now();
      }

      final endTimeStr = json['end_time']?.toString() ?? '';
      DateTime endTime;
      try {
        endTime = DateTime.parse(endTimeStr);
      } catch (_) {
        endTime = dateTime.add(const Duration(hours: 1));
      }

      final durationMin = _parseInt(json['duration']);
      final duration = durationMin > 0 
          ? Duration(minutes: durationMin)
          : endTime.difference(dateTime);

      final location = json['location']?.toString() ?? '';
      
      // Determine EventType using schedule_game_id / name heuristics
      EventType type = EventType.other;
      if (json['schedule_game_id'] != null) {
        type = EventType.game;
      } else {
        final lowerTitle = title.toLowerCase();
        if (lowerTitle.contains('practice') || lowerTitle.contains('training')) {
          type = EventType.practice;
        } else if (lowerTitle.contains('game') || lowerTitle.contains('scrimmage') || lowerTitle.contains('match')) {
          type = EventType.game;
        }
      }

      final opponent = json['opponant']?.toString() ?? json['opponent']?.toString();
      final trackAvailability = _parseBool(json['track_availability']);
      final notes = json['notes']?.toString();

      // Attendance counts mapping to lists of dummy strings of correct lengths so that
      // existing RSVP logic computes correct numbers.
      final attendanceCounts = json['attendance_counts'] as Map<String, dynamic>?;
      int goingCount = 0;
      int maybeCount = 0;
      int noCount = 0;

      if (attendanceCounts != null) {
        goingCount = _parseInt(attendanceCounts['going']);
        maybeCount = _parseInt(attendanceCounts['maybe']);
        noCount = _parseInt(attendanceCounts['no']);
      }

      // Check if user has an RSVP already to avoid double counting or set correct initial state
      final myRsvpMap = json['my_rsvp'] as Map<String, dynamic>?;
      String? myRsvpStatus;
      final bool requiresPlayerSelection = myRsvpMap != null ? _parseBool(myRsvpMap['requires_player_selection']) : false;
      final List<ClubEventRsvpTarget> rsvpTargets = [];
      
      if (myRsvpMap != null) {
        // Explicitly check for null so that integer 0 (= No) is never skipped
        final dynamic rawAttendance = myRsvpMap['attendance'];
        if (rawAttendance != null) {
          myRsvpStatus = rawAttendance.toString().toLowerCase();
          if (myRsvpStatus == 'null' || myRsvpStatus == '') myRsvpStatus = null;
        }
        final targetsList = myRsvpMap['targets'] as List?;
        if (targetsList != null) {
          if (myRsvpStatus == null && targetsList.isNotEmpty) {
            final dynamic rawTargetAttendance =
                (targetsList.first as Map<String, dynamic>?)?['attendance'];
            if (rawTargetAttendance != null) {
              myRsvpStatus = rawTargetAttendance.toString().toLowerCase();
              if (myRsvpStatus == 'null' || myRsvpStatus == '') myRsvpStatus = null;
            }
          }
          for (final t in targetsList) {
            if (t is Map<String, dynamic>) {
              rsvpTargets.add(
                ClubEventRsvpTarget(
                  attendeeType: t['attendee_type']?.toString() ?? '',
                  customerId: _parseInt(t['customer_id']),
                  playerId: t['player_id'] != null ? _parseInt(t['player_id']) : null,
                  name: t['name']?.toString() ?? '',
                  teamEventAttendeeId: t['team_event_attendee_id'] != null ? _parseInt(t['team_event_attendee_id']) : null,
                  attendance: t['attendance'],
                  notes: t['notes']?.toString() ?? '',
                ),
              );
            }
          }
        }
      }

      final List<String> rsvpYes = [];
      final List<String> rsvpMaybe = [];
      final List<String> rsvpNo = [];

      if (myRsvpStatus == 'going' || myRsvpStatus == 'yes' || myRsvpStatus == '1') {
        rsvpYes.add('me');
        final remaining = (goingCount - 1).clamp(0, 999999);
        rsvpYes.addAll(List.generate(remaining, (i) => 'player_yes_$i'));
        rsvpMaybe.addAll(List.generate(maybeCount, (i) => 'player_maybe_$i'));
        rsvpNo.addAll(List.generate(noCount, (i) => 'player_no_$i'));
      } else if (myRsvpStatus == 'maybe' || myRsvpStatus == '2') {
        rsvpMaybe.add('me');
        rsvpYes.addAll(List.generate(goingCount, (i) => 'player_yes_$i'));
        final remaining = (maybeCount - 1).clamp(0, 999999);
        rsvpMaybe.addAll(List.generate(remaining, (i) => 'player_maybe_$i'));
        rsvpNo.addAll(List.generate(noCount, (i) => 'player_no_$i'));
      } else if (myRsvpStatus == 'no' || myRsvpStatus == '0' || myRsvpStatus == '3') {
        rsvpNo.add('me');
        rsvpYes.addAll(List.generate(goingCount, (i) => 'player_yes_$i'));
        rsvpMaybe.addAll(List.generate(maybeCount, (i) => 'player_maybe_$i'));
        final remaining = (noCount - 1).clamp(0, 999999);
        rsvpNo.addAll(List.generate(remaining, (i) => 'player_no_$i'));
      } else {
        rsvpYes.addAll(List.generate(goingCount, (i) => 'player_yes_$i'));
        rsvpMaybe.addAll(List.generate(maybeCount, (i) => 'player_maybe_$i'));
        rsvpNo.addAll(List.generate(noCount, (i) => 'player_no_$i'));
      }

      final timeTbd = _parseBool(json['time_tbd']);
      final timeLabel = json['time_label']?.toString();
      final locationDetails = json['location_details']?.toString();
      final uniformColor = json['uniform_color']?.toString();
      final arrivalTime = json['arrival_time']?.toString();
      final flagColor = json['flag_color']?.toString();
      final dbId = _parseInt(json['team_event_id'] ?? json['id']);
      final timezone = json['timezone']?.toString();
      final notificationEnabled = _parseBool(json['notification_enabled'] ?? true);
      final arrivalEarly = json['arrival_early'] != null ? _parseInt(json['arrival_early']) : 15;
      final latitude = json['latitude']?.toString() ?? '';
      final longitude = json['longitude']?.toString() ?? '';
      final scheduleGameId = json['schedule_game_id'] != null ? _parseInt(json['schedule_game_id']) : null;

      return ClubEvent(
        id: uuid,
        title: title,
        subtitle: subtitle,
        dateTime: dateTime,
        duration: duration,
        location: location,
        type: type,
        isHome: true, // fallback default
        opponent: opponent,
        rsvpRequired: trackAvailability,
        notes: notes,
        rsvpYes: rsvpYes,
        rsvpMaybe: rsvpMaybe,
        rsvpNo: rsvpNo,
        timeTbd: timeTbd,
        timeLabel: timeLabel,
        locationDetails: locationDetails,
        uniformColor: uniformColor,
        arrivalTime: arrivalTime,
        flagColor: flagColor,
        dbId: dbId,
        timezone: timezone,
        notificationEnabled: notificationEnabled,
        arrivalEarly: arrivalEarly,
        scheduleGameId: scheduleGameId,
        latitude: latitude,
        longitude: longitude,
        requiresPlayerSelection: requiresPlayerSelection,
        rsvpTargets: rsvpTargets,
      );
    } catch (e) {
      debugPrint('[HomeService] Error parsing event: $e');
      return null;
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
    }
    return false;
  }
}
