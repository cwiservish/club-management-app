// ─── Resilient parsing helpers ────────────────────────────────────────────────

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
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

// ─── Models for Event Availability API ───────────────────────────────────────

class EventAvailabilityRequest {
  final String teamUuid;
  final String eventUuid;

  EventAvailabilityRequest({
    required this.teamUuid,
    required this.eventUuid,
  });

  Map<String, dynamic> toJson() => {
    'team_uuid': teamUuid,
    'event_uuid': eventUuid,
  };
}

class EventAvailabilityResponse {
  final bool success;
  final String message;
  final EventAvailabilityData? data;

  const EventAvailabilityResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EventAvailabilityResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EventAvailabilityResponse(
        success: false,
        message: 'No response data available',
      );
    }
    return EventAvailabilityResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: json['data'] != null ? EventAvailabilityData.fromJson(json['data'] as Map<String, dynamic>?) : null,
    );
  }
}

class EventAvailabilityData {
  final AvailabilityEventDetail? event;
  final List<AvailabilityGroup> groups;

  const EventAvailabilityData({
    this.event,
    required this.groups,
  });

  factory EventAvailabilityData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EventAvailabilityData(
        groups: [],
      );
    }

    final groupsList = json['groups'] as List?;
    final parsedGroups = groupsList != null
        ? groupsList
            .map((e) => e is Map<String, dynamic> ? AvailabilityGroup.fromJson(e) : null)
            .whereType<AvailabilityGroup>()
            .toList()
        : <AvailabilityGroup>[];

    return EventAvailabilityData(
      event: json['event'] != null ? AvailabilityEventDetail.fromJson(json['event'] as Map<String, dynamic>?) : null,
      groups: parsedGroups,
    );
  }
}

class AvailabilityEventDetail {
  final int id;
  final int teamEventId;
  final String uuid;
  final String teamEventUuid;
  final String eventName;

  const AvailabilityEventDetail({
    required this.id,
    required this.teamEventId,
    required this.uuid,
    required this.teamEventUuid,
    required this.eventName,
  });

  factory AvailabilityEventDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AvailabilityEventDetail(
        id: 0,
        teamEventId: 0,
        uuid: '',
        teamEventUuid: '',
        eventName: '',
      );
    }
    return AvailabilityEventDetail(
      id: _parseInt(json['id']),
      teamEventId: _parseInt(json['team_event_id'] ?? json['id']),
      uuid: _parseString(json['uuid']),
      teamEventUuid: _parseString(json['team_event_uuid'] ?? json['uuid']),
      eventName: _parseString(json['event_name']),
    );
  }
}

class AvailabilityGroup {
  final String key;
  final String label;
  final int? attendance;
  final List<AvailabilityPlayer> players;
  final int count;

  const AvailabilityGroup({
    required this.key,
    required this.label,
    this.attendance,
    required this.players,
    required this.count,
  });

  factory AvailabilityGroup.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AvailabilityGroup(
        key: '',
        label: '',
        players: [],
        count: 0,
      );
    }

    final playersList = json['players'] as List?;
    final parsedPlayers = playersList != null
        ? playersList
            .map((e) => e is Map<String, dynamic> ? AvailabilityPlayer.fromJson(e) : null)
            .whereType<AvailabilityPlayer>()
            .toList()
        : <AvailabilityPlayer>[];

    return AvailabilityGroup(
      key: _parseString(json['key']),
      label: _parseString(json['label']),
      attendance: json['attendance'] != null ? _parseInt(json['attendance']) : null,
      players: parsedPlayers,
      count: _parseInt(json['count'] ?? parsedPlayers.length),
    );
  }
}

class AvailabilityPlayer {
  final int teamPlayerId;
  final int playerId;
  final String uuid;
  final String firstName;
  final String lastName;
  final String name;
  final String dateOfBirth;
  final String gender;
  final int heightFeet;
  final int heightInches;
  final int heightTotalInches;
  final String jerseyNo;
  final String imageUrl;
  final String profileImageUrl;
  final String profileUrl;
  final String parentVerified;
  final String parentRegistered;
  final String guest;
  final String location;
  final String gradYear;
  final String primaryPosition;
  final String otherPositions;
  final bool canUpdate;
  final bool isMyPlayer;
  final int? teamEventAttendeeId;
  final int? attendance;
  final String notes;

  const AvailabilityPlayer({
    required this.teamPlayerId,
    required this.playerId,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.heightFeet,
    required this.heightInches,
    required this.heightTotalInches,
    required this.jerseyNo,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.profileUrl,
    required this.parentVerified,
    required this.parentRegistered,
    required this.guest,
    required this.location,
    required this.gradYear,
    required this.primaryPosition,
    required this.otherPositions,
    required this.canUpdate,
    required this.isMyPlayer,
    this.teamEventAttendeeId,
    this.attendance,
    required this.notes,
  });

  factory AvailabilityPlayer.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AvailabilityPlayer(
        teamPlayerId: 0,
        playerId: 0,
        uuid: '',
        firstName: '',
        lastName: '',
        name: '',
        dateOfBirth: '',
        gender: '',
        heightFeet: 0,
        heightInches: 0,
        heightTotalInches: 0,
        jerseyNo: '',
        imageUrl: '',
        profileImageUrl: '',
        profileUrl: '',
        parentVerified: '',
        parentRegistered: '',
        guest: '',
        location: '',
        gradYear: '',
        primaryPosition: '',
        otherPositions: '',
        canUpdate: false,
        isMyPlayer: false,
        notes: '',
      );
    }

    return AvailabilityPlayer(
      teamPlayerId: _parseInt(json['team_player_id']),
      playerId: _parseInt(json['player_id']),
      uuid: _parseString(json['uuid']),
      firstName: _parseString(json['first_name']),
      lastName: _parseString(json['last_name']),
      name: _parseString(json['name']),
      dateOfBirth: _parseString(json['date_of_birth']),
      gender: _parseString(json['gender']),
      heightFeet: _parseInt(json['height_feet']),
      heightInches: _parseInt(json['height_inches']),
      heightTotalInches: _parseInt(json['height_total_inches']),
      jerseyNo: _parseString(json['jersey_no']),
      imageUrl: _parseString(json['image_url']),
      profileImageUrl: _parseString(json['profile_image_url']),
      profileUrl: _parseString(json['profile_url']),
      parentVerified: _parseString(json['parent_verified']),
      parentRegistered: _parseString(json['parent_registered']),
      guest: _parseString(json['guest']),
      location: _parseString(json['location']),
      gradYear: _parseString(json['grad_year']),
      primaryPosition: _parseString(json['primary_position']),
      otherPositions: _parseString(json['other_positions']),
      canUpdate: _parseBool(json['can_update']),
      isMyPlayer: _parseBool(json['is_my_player']),
      teamEventAttendeeId: json['team_event_attendee_id'] != null ? _parseInt(json['team_event_attendee_id']) : null,
      attendance: json['attendance'] != null ? _parseInt(json['attendance']) : null,
      notes: _parseString(json['notes']),
    );
  }
}

class EventAttendeeSaveRequest {
  final String teamUuid;
  final int teamEventId;
  final String attendeeType;
  final String customerId;
  final int playerId;
  final String notes;
  final int? attendance;

  EventAttendeeSaveRequest({
    required this.teamUuid,
    required this.teamEventId,
    this.attendeeType = 'player',
    this.customerId = '',
    required this.playerId,
    required this.notes,
    this.attendance,
  });

  Map<String, dynamic> toJson() => {
    'team_uuid': teamUuid,
    'team_event_id': teamEventId,
    'attendee_type': attendeeType,
    'customer_id': customerId,
    'player_id': playerId,
    'notes': notes,
    if (attendance != null) 'attendance': attendance,
  };
}

class EventAttendeeSaveResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const EventAttendeeSaveResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EventAttendeeSaveResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EventAttendeeSaveResponse(
        success: false,
        message: 'No response data available',
      );
    }
    return EventAttendeeSaveResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
    );
  }
}
