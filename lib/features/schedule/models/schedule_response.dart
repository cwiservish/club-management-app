import '../../../core/enums/event_type.dart';
import '../../../core/models/club_event.dart';

// ─── Helpers for Crash-Proof Null Safety ────────────────────────────────────

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is int) return val == 1;
  if (val is String) {
    final lower = val.toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
  }
  return false;
}

String _parseString(dynamic val) {
  if (val == null) return '';
  return val.toString();
}

// ─── Response Models ────────────────────────────────────────────────────────

class ScheduleAllEventsResponse {
  final bool success;
  final String message;
  final ScheduleData? data;

  const ScheduleAllEventsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ScheduleAllEventsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ScheduleAllEventsResponse(
        success: false,
        message: 'No response data available',
      );
    }
    return ScheduleAllEventsResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: json['data'] != null ? ScheduleData.fromJson(json['data'] as Map<String, dynamic>?) : null,
    );
  }
}

class ScheduleData {
  final List<ScheduleMonth> months;

  const ScheduleData({
    required this.months,
  });

  factory ScheduleData.fromJson(Map<String, dynamic>? json) {
    final list = json?['months'] as List?;
    final parsedMonths = list != null
        ? list
            .map((e) => e is Map<String, dynamic> ? ScheduleMonth.fromJson(e) : null)
            .whereType<ScheduleMonth>()
            .toList()
        : <ScheduleMonth>[];
    return ScheduleData(months: parsedMonths);
  }
}

class ScheduleMonth {
  final String key;
  final String label;
  final List<ScheduleEvent> events;

  const ScheduleMonth({
    required this.key,
    required this.label,
    required this.events,
  });

  factory ScheduleMonth.fromJson(Map<String, dynamic>? json) {
    final list = json?['events'] as List?;
    final parsedEvents = list != null
        ? list
            .map((e) => e is Map<String, dynamic> ? ScheduleEvent.fromJson(e) : null)
            .whereType<ScheduleEvent>()
            .toList()
        : <ScheduleEvent>[];
    return ScheduleMonth(
      key: _parseString(json?['key']),
      label: _parseString(json?['label']),
      events: parsedEvents,
    );
  }
}

class ScheduleEvent {
  final int id;
  final int teamEventId;
  final String uuid;
  final int teamId;
  final int? scheduleGameId;
  final String eventName;
  final String eventDate;
  final String dateLabel;
  final String day;
  final String dayName;
  final String monthKey;
  final String monthLabel;
  final String startTime;
  final String endTime;
  final String timeLabel;
  final String timezone;
  final bool timeTbd;
  final int duration;
  final String location;
  final String locationDetails;
  final String latitude;
  final String longitude;
  final int arrivalEarly;
  final String arrivalTime;
  final bool trackAvailability;
  final String flagColor;
  final String uniformColor;
  final String opponent;
  final String extraLabel;
  final String notes;
  final int status;
  final bool notificationEnabled;
  final AttendanceCounts? attendanceCounts;
  final MyRsvp? myRsvp;
  final List<RsvpTarget> rsvpTargets;

  const ScheduleEvent({
    required this.id,
    required this.teamEventId,
    required this.uuid,
    required this.teamId,
    this.scheduleGameId,
    required this.eventName,
    required this.eventDate,
    required this.dateLabel,
    required this.day,
    required this.dayName,
    required this.monthKey,
    required this.monthLabel,
    required this.startTime,
    required this.endTime,
    required this.timeLabel,
    required this.timezone,
    required this.timeTbd,
    required this.duration,
    required this.location,
    required this.locationDetails,
    required this.latitude,
    required this.longitude,
    required this.arrivalEarly,
    required this.arrivalTime,
    required this.trackAvailability,
    required this.flagColor,
    required this.uniformColor,
    required this.opponent,
    required this.extraLabel,
    required this.notes,
    required this.status,
    required this.notificationEnabled,
    this.attendanceCounts,
    this.myRsvp,
    required this.rsvpTargets,
  });

  factory ScheduleEvent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ScheduleEvent(
        id: 0,
        teamEventId: 0,
        uuid: '',
        teamId: 0,
        eventName: '',
        eventDate: '',
        dateLabel: '',
        day: '',
        dayName: '',
        monthKey: '',
        monthLabel: '',
        startTime: '',
        endTime: '',
        timeLabel: '',
        timezone: '',
        timeTbd: false,
        duration: 0,
        location: '',
        locationDetails: '',
        latitude: '',
        longitude: '',
        arrivalEarly: 0,
        arrivalTime: '',
        trackAvailability: false,
        flagColor: '',
        uniformColor: '',
        opponent: '',
        extraLabel: '',
        notes: '',
        status: 0,
        notificationEnabled: false,
        rsvpTargets: [],
      );
    }

    final targetsList = json['rsvp_targets'] as List?;
    final parsedTargets = targetsList != null
        ? targetsList
            .map((e) => e is Map<String, dynamic> ? RsvpTarget.fromJson(e) : null)
            .whereType<RsvpTarget>()
            .toList()
        : <RsvpTarget>[];

    return ScheduleEvent(
      id: _parseInt(json['id']),
      teamEventId: _parseInt(json['team_event_id']),
      uuid: _parseString(json['uuid']),
      teamId: _parseInt(json['team_id']),
      scheduleGameId: json['schedule_game_id'] != null ? _parseInt(json['schedule_game_id']) : null,
      eventName: _parseString(json['event_name']),
      eventDate: _parseString(json['event_date']),
      dateLabel: _parseString(json['date_label']),
      day: _parseString(json['day']),
      dayName: _parseString(json['day_name']),
      monthKey: _parseString(json['month_key']),
      monthLabel: _parseString(json['month_label']),
      startTime: _parseString(json['start_time']),
      endTime: _parseString(json['end_time']),
      timeLabel: _parseString(json['time_label']),
      timezone: _parseString(json['timezone']),
      timeTbd: _parseBool(json['time_tbd']),
      duration: _parseInt(json['duration']),
      location: _parseString(json['location']),
      locationDetails: _parseString(json['location_details']),
      latitude: _parseString(json['latitude']),
      longitude: _parseString(json['longitude']),
      arrivalEarly: _parseInt(json['arrival_early']),
      arrivalTime: _parseString(json['arrival_time']),
      trackAvailability: _parseBool(json['track_availability']),
      flagColor: _parseString(json['flag_color']),
      uniformColor: _parseString(json['uniform_color']),
      opponent: _parseString(json['opponant'] ?? json['opponent']),
      extraLabel: _parseString(json['extra_label']),
      notes: _parseString(json['notes']),
      status: _parseInt(json['status']),
      notificationEnabled: _parseBool(json['notification_enabled']),
      attendanceCounts: json['attendance_counts'] != null
          ? AttendanceCounts.fromJson(json['attendance_counts'] as Map<String, dynamic>?)
          : null,
      myRsvp: json['my_rsvp'] != null ? MyRsvp.fromJson(json['my_rsvp'] as Map<String, dynamic>?) : null,
      rsvpTargets: parsedTargets,
    );
  }

  /// Converts this highly resilient model into the application's domain [ClubEvent].
  ClubEvent toDomain() {
    // 1. Base details parsing
    final String domainId = uuid.isNotEmpty ? uuid : id.toString();
    
    // Parse times safely
    DateTime parsedDateTime;
    try {
      parsedDateTime = DateTime.parse(startTime.isNotEmpty ? startTime : eventDate);
    } catch (_) {
      parsedDateTime = DateTime.now();
    }

    DateTime parsedEndTime;
    try {
      parsedEndTime = DateTime.parse(endTime);
    } catch (_) {
      parsedEndTime = parsedDateTime.add(Duration(minutes: duration > 0 ? duration : 60));
    }

    final computedDuration = duration > 0 ? Duration(minutes: duration) : parsedEndTime.difference(parsedDateTime);

    // 2. Identify EventType using helper heuristics matching HomeService
    EventType domainType = EventType.other;
    if (scheduleGameId != null) {
      domainType = EventType.game;
    } else {
      final lowerTitle = eventName.toLowerCase();
      if (lowerTitle.contains('practice') || lowerTitle.contains('training')) {
        domainType = EventType.practice;
      } else if (lowerTitle.contains('game') || lowerTitle.contains('scrimmage') || lowerTitle.contains('match')) {
        domainType = EventType.game;
      }
    }

    // 3. Build RSVP counts (yes/no/maybe lists matching HomeService logic)
    final int goingCount = attendanceCounts?.going ?? 0;
    final int maybeCount = attendanceCounts?.maybe ?? 0;
    final int noCount = attendanceCounts?.no ?? 0;

    String? myRsvpStatus;
    if (myRsvp != null) {
      // Explicitly check for null so that integer 0 (= No) is never skipped
      final dynamic rawAttendance = myRsvp!.attendance;
      if (rawAttendance != null) {
        myRsvpStatus = rawAttendance.toString().toLowerCase();
        if (myRsvpStatus == 'null' || myRsvpStatus == '') myRsvpStatus = null;
      }
      final targetsList = myRsvp!.targets;
      if (myRsvpStatus == null && targetsList.isNotEmpty) {
        final dynamic rawTargetAttendance = targetsList.first.attendance;
        if (rawTargetAttendance != null) {
          myRsvpStatus = rawTargetAttendance.toString().toLowerCase();
          if (myRsvpStatus == 'null' || myRsvpStatus == '') myRsvpStatus = null;
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
    } else if (myRsvpStatus == 'no' || myRsvpStatus == '0') {
      rsvpNo.add('me');
      rsvpYes.addAll(List.generate(goingCount, (i) => 'player_yes_$i'));
      rsvpMaybe.addAll(List.generate(maybeCount, (i) => 'player_maybe_$i'));
      final remaining = (noCount - 1).clamp(0, 999999);
      rsvpNo.addAll(List.generate(remaining, (i) => 'player_no_$i'));
    } else {
      // No recognized RSVP status — add raw counts only
      rsvpYes.addAll(List.generate(goingCount, (i) => 'player_yes_$i'));
      rsvpMaybe.addAll(List.generate(maybeCount, (i) => 'player_maybe_$i'));
      rsvpNo.addAll(List.generate(noCount, (i) => 'player_no_$i'));
    }

    final bool requiresPlayerSelection = myRsvp?.requiresPlayerSelection ?? false;
    final List<ClubEventRsvpTarget> domainTargets = [];
    if (myRsvp != null) {
      for (final t in myRsvp!.targets) {
        domainTargets.add(
          ClubEventRsvpTarget(
            attendeeType: t.attendeeType,
            customerId: t.customerId,
            playerId: t.playerId,
            name: t.name,
            teamEventAttendeeId: t.teamEventAttendeeId,
            attendance: t.attendance,
            notes: t.notes,
          ),
        );
      }
    }

    return ClubEvent(
      id: domainId,
      title: eventName.isNotEmpty ? eventName : 'Event',
      subtitle: extraLabel,
      dateTime: parsedDateTime,
      duration: computedDuration,
      location: location,
      type: domainType,
      isHome: true,
      opponent: opponent.isNotEmpty ? opponent : null,
      rsvpRequired: trackAvailability,
      notes: notes.isNotEmpty ? notes : null,
      rsvpYes: rsvpYes,
      rsvpMaybe: rsvpMaybe,
      rsvpNo: rsvpNo,
      timeTbd: timeTbd,
      timeLabel: timeLabel.isNotEmpty ? timeLabel : null,
      locationDetails: locationDetails.isNotEmpty ? locationDetails : null,
      uniformColor: uniformColor.isNotEmpty ? uniformColor : null,
      arrivalTime: arrivalTime.isNotEmpty ? arrivalTime : null,
      flagColor: flagColor.isNotEmpty ? flagColor : null,
      dbId: teamEventId > 0 ? teamEventId : id,
      timezone: timezone.isNotEmpty ? timezone : null,
      notificationEnabled: notificationEnabled,
      arrivalEarly: arrivalEarly,
      requiresPlayerSelection: requiresPlayerSelection,
      rsvpTargets: domainTargets,
    );
  }
}

class AttendanceCounts {
  final int going;
  final int maybe;
  final int no;

  const AttendanceCounts({
    required this.going,
    required this.maybe,
    required this.no,
  });

  factory AttendanceCounts.fromJson(Map<String, dynamic>? json) {
    return AttendanceCounts(
      going: _parseInt(json?['going']),
      maybe: _parseInt(json?['maybe']),
      no: _parseInt(json?['no']),
    );
  }
}

class MyRsvp {
  final dynamic attendance;
  final bool requiresPlayerSelection;
  final List<RsvpTargetDetail> targets;

  const MyRsvp({
    required this.attendance,
    required this.requiresPlayerSelection,
    required this.targets,
  });

  factory MyRsvp.fromJson(Map<String, dynamic>? json) {
    final list = json?['targets'] as List?;
    final parsedTargets = list != null
        ? list
            .map((e) => e is Map<String, dynamic> ? RsvpTargetDetail.fromJson(e) : null)
            .whereType<RsvpTargetDetail>()
            .toList()
        : <RsvpTargetDetail>[];
    return MyRsvp(
      attendance: json?['attendance'],
      requiresPlayerSelection: _parseBool(json?['requires_player_selection']),
      targets: parsedTargets,
    );
  }
}

class RsvpTargetDetail {
  final String attendeeType;
  final int customerId;
  final int? playerId;
  final String name;
  final int? teamEventAttendeeId;
  final dynamic attendance;
  final String notes;

  const RsvpTargetDetail({
    required this.attendeeType,
    required this.customerId,
    this.playerId,
    required this.name,
    this.teamEventAttendeeId,
    required this.attendance,
    required this.notes,
  });

  factory RsvpTargetDetail.fromJson(Map<String, dynamic>? json) {
    return RsvpTargetDetail(
      attendeeType: _parseString(json?['attendee_type']),
      customerId: _parseInt(json?['customer_id']),
      playerId: json?['player_id'] != null ? _parseInt(json?['player_id']) : null,
      name: _parseString(json?['name']),
      teamEventAttendeeId: json?['team_event_attendee_id'] != null ? _parseInt(json?['team_event_attendee_id']) : null,
      attendance: json?['attendance'],
      notes: _parseString(json?['notes']),
    );
  }
}

class RsvpTarget {
  final String attendeeType;
  final int customerId;
  final int? playerId;
  final String name;

  const RsvpTarget({
    required this.attendeeType,
    required this.customerId,
    this.playerId,
    required this.name,
  });

  factory RsvpTarget.fromJson(Map<String, dynamic>? json) {
    return RsvpTarget(
      attendeeType: _parseString(json?['attendee_type']),
      customerId: _parseInt(json?['customer_id']),
      playerId: json?['player_id'] != null ? _parseInt(json?['player_id']) : null,
      name: _parseString(json?['name']),
    );
  }
}
