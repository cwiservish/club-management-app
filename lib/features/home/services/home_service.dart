import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/models/club_event.dart';
import '../../../core/enums/event_type.dart';

class HomeService {
  final ApiClient _apiClient;

  HomeService(this._apiClient);

  /// Fetch events list from the QA endpoint for a specific team.
  /// Returns a record containing the list of events and an optional sponsor banner URL.
  Future<({List<ClubEvent> events, String? bannerImageUrl})> fetchEvents(String teamUuid) async {
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

      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Response] POST $endpoint');
      debugPrint('[API Response success]: ${response.success}');
      debugPrint('[API Response Body length]: ${response.data != null ? response.data.toString().length : 0}');
      debugPrint('════════════════════════════════════════════════════════════════');

      if (!response.success || response.data == null) {
        return (events: <ClubEvent>[], bannerImageUrl: null);
      }

      final dataMap = response.data as Map<String, dynamic>?;
      if (dataMap == null) return (events: <ClubEvent>[], bannerImageUrl: null);

      // Parse optional sponsor banner URL (field name may vary by API version)
      final bannerImageUrl = dataMap['banner_image']?.toString()
          ?? dataMap['sponsor_image']?.toString()
          ?? dataMap['banner_url']?.toString();

      final grid = dataMap['grid'] as List?;
      if (grid == null) return (events: <ClubEvent>[], bannerImageUrl: bannerImageUrl);

      final List<ClubEvent> events = [];
      for (final item in grid) {
        if (item is Map<String, dynamic>) {
          final event = _parseClubEvent(item);
          if (event != null) {
            events.add(event);
          }
        }
      }

      return (events: events, bannerImageUrl: bannerImageUrl);
    } catch (e, stackTrace) {
      debugPrint('[HomeService] Error fetching events: $e');
      debugPrint(stackTrace.toString());
      return (events: <ClubEvent>[], bannerImageUrl: null);
    }
  }


  /// Crash-proof parser from QA JSON item to ClubEvent domain model.
  ClubEvent? _parseClubEvent(Map<String, dynamic> json) {
    try {
      final uuid = json['uuid']?.toString() ?? json['id']?.toString() ?? '';
      if (uuid.isEmpty) return null;

      // display_name is the canonical display title in the new API
      final title = json['display_name']?.toString()
          ?? json['title']?.toString()
          ?? json['event_name']?.toString()
          ?? 'Event';
      final subtitle = json['extra_label']?.toString() ?? '';

      // Combine session_date + start_time into a full DateTime.
      // start_time is "HH:mm:ss" (time only), session_date is "yyyy-MM-dd".
      final sessionDate = json['session_date']?.toString() ?? '';
      final startTimeStr = json['start_time']?.toString() ?? '';
      DateTime dateTime;
      try {
        if (sessionDate.isNotEmpty && startTimeStr.isNotEmpty) {
          dateTime = DateTime.parse('$sessionDate $startTimeStr');
        } else {
          dateTime = DateTime.parse(startTimeStr);
        }
      } catch (_) {
        dateTime = DateTime.now();
      }

      final endTimeStr = json['end_time']?.toString() ?? '';
      DateTime endTime;
      try {
        if (sessionDate.isNotEmpty && endTimeStr.isNotEmpty) {
          endTime = DateTime.parse('$sessionDate $endTimeStr');
        } else {
          endTime = DateTime.parse(endTimeStr);
        }
      } catch (_) {
        endTime = dateTime.add(const Duration(hours: 1));
      }

      final durationMin = _parseInt(json['duration']);
      final duration = durationMin > 0
          ? Duration(minutes: durationMin)
          : endTime.difference(dateTime);

      final location = json['location']?.toString() ?? '';

      // Map event_type int from API → EventType enum
      // 1=Game, 2=Practice, 3=Scrimmage (→game), 4=Team Event, 5=Camp
      final eventTypeInt = _parseInt(json['event_type']);
      EventType type;
      switch (eventTypeInt) {
        case 1:
        case 3:
          type = EventType.game;
        case 2:
          type = EventType.practice;
        default:
          type = EventType.other;
      }

      final opponent = json['opponent_team_name']?.toString()
          ?? json['opponant']?.toString()
          ?? json['opponent']?.toString();
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
                  // new API uses attendee_id; old used customer_id
                  customerId: _parseInt(t['attendee_id'] ?? t['customer_id']),
                  playerId: t['player_id'] != null ? _parseInt(t['player_id']) : null,
                  name: t['name']?.toString() ?? '',
                  // new API uses team_event_session_attendee_id
                  teamEventAttendeeId: _parseInt(
                    t['team_event_session_attendee_id'] ?? t['team_event_attendee_id'],
                  ) > 0 ? _parseInt(t['team_event_session_attendee_id'] ?? t['team_event_attendee_id']) : null,
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
      final dateLabel = json['date_label']?.toString();
      final locationDetails = json['location_details']?.toString();
      final uniformColor = json['uniform_color']?.toString();
      final arrivalTime = json['arrival_time']?.toString();
      final flagColor = json['flag_color']?.toString();
      // New API uses numeric 'id'; keep 'team_event_id' as fallback for older responses
      final dbId = _parseInt(json['id'] ?? json['team_event_id']);
      final timezone = json['timezone']?.toString();
      final notificationEnabled = _parseBool(json['notification_enabled'] ?? true);
      final arrivalEarly = json['arrival_early'] != null ? _parseInt(json['arrival_early']) : 0;
      final latitude = json['latitude']?.toString() ?? '';
      final longitude = json['longitude']?.toString() ?? '';
      final scheduleGameId = _parseInt(json['schedule_game_id']) > 0 ? _parseInt(json['schedule_game_id']) : null;
      final status = _parseInt(json['status'] ?? 1);
      // home_away: 1=Home, 2=Away, 3=Neutral
      final isHome = _parseInt(json['home_away']) == 1;

      return ClubEvent(
        id: uuid,
        title: title,
        subtitle: subtitle,
        dateTime: dateTime,
        duration: duration,
        location: location,
        type: type,
        isHome: isHome,
        opponent: (opponent?.isNotEmpty == true) ? opponent : null,
        rsvpRequired: trackAvailability,
        notes: notes,
        rsvpYes: rsvpYes,
        rsvpMaybe: rsvpMaybe,
        rsvpNo: rsvpNo,
        timeTbd: timeTbd,
        timeLabel: timeLabel,
        dateLabel: dateLabel,
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
        status: status,
      );
    } catch (e) {
      debugPrint('[HomeService] Error parsing event: $e');
      return null;
    }
  }

  Future<({bool success, String message})> saveEventRsvp({
    required String teamUuid,
    required int teamEventId,
    required String attendeeType,
    required String customerId,
    required int playerId,
    required String notes,
    required int attendance,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.eventAttendeeSave,
      body: {
        'team_uuid': teamUuid,
        'team_event_id': teamEventId,
        'attendee_type': attendeeType,
        'customer_id': customerId,
        'player_id': playerId,
        'notes': notes,
        'attendance': attendance,
      },
    );
    return (success: response.success, message: response.message ?? '');
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
