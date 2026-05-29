class EventSaveRequest {
  final String teamUuid;
  final String eventName;
  final dynamic id; // Dynamic to support both String and int values safely
  final String startTime;
  final String timezone;
  final bool timeTbd;
  final int duration;
  final String location;
  final String latitude;
  final String longitude;
  final String? locationDetails;
  final int arrivalEarly;
  final bool trackAvailability;
  final String flagColor;
  final String uniformColor;
  final String opponent;
  final String extraLabel;
  final String notes;
  final int status;
  final bool notificationEnabled;

  EventSaveRequest({
    required this.teamUuid,
    required this.eventName,
    this.id,
    required this.startTime,
    required this.timezone,
    required this.timeTbd,
    required this.duration,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.locationDetails,
    required this.arrivalEarly,
    required this.trackAvailability,
    required this.flagColor,
    required this.uniformColor,
    required this.opponent,
    required this.extraLabel,
    required this.notes,
    this.status = 1,
    required this.notificationEnabled,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'team_uuid': teamUuid,
      'event_name': eventName,
      'start_time': startTime,
      'timezone': timezone,
      'time_tbd': timeTbd,
      'duration': duration,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'location_details': locationDetails,
      'arrival_early': arrivalEarly,
      'track_availability': trackAvailability,
      'flag_color': flagColor,
      'uniform_color': uniformColor,
      'opponant': opponent, // exact key expected by the API
      'extra_label': extraLabel,
      'notes': notes,
      'status': status,
      'notification_enabled': notificationEnabled,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}

class EventSaveResponse {
  final bool success;
  final String message;
  final EventSaveData? data;

  EventSaveResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EventSaveResponse.fromJson(Map<String, dynamic> json) {
    return EventSaveResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EventSaveData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EventSaveData {
  final int? teamEventId;
  final String uuid;
  final int? teamId;
  final dynamic scheduleGameId;
  final String eventName;
  final String eventDate;
  final String startTime;
  final String endTime;
  final String timezone;
  final bool timeTbd;
  final int duration;
  final String location;
  final String? locationDetails;
  final String latitude;
  final String longitude;
  final int arrivalEarly;
  final bool trackAvailability;
  final String flagColor;
  final String uniformColor;
  final String opponent;
  final String extraLabel;
  final String notes;
  final int status;
  final bool notificationEnabled;
  final int? createdBy;
  final String? createdByType;
  final int? updatedBy;
  final String? updatedByType;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  EventSaveData({
    this.teamEventId,
    required this.uuid,
    this.teamId,
    this.scheduleGameId,
    required this.eventName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.timezone,
    required this.timeTbd,
    required this.duration,
    required this.location,
    this.locationDetails,
    required this.latitude,
    required this.longitude,
    required this.arrivalEarly,
    required this.trackAvailability,
    required this.flagColor,
    required this.uniformColor,
    required this.opponent,
    required this.extraLabel,
    required this.notes,
    required this.status,
    required this.notificationEnabled,
    this.createdBy,
    this.createdByType,
    this.updatedBy,
    this.updatedByType,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory EventSaveData.fromJson(Map<String, dynamic> json) {
    return EventSaveData(
      teamEventId: _parseInt(json['team_event_id']),
      uuid: json['uuid']?.toString() ?? '',
      teamId: _parseInt(json['team_id']),
      scheduleGameId: json['schedule_game_id'],
      eventName: json['event_name']?.toString() ?? '',
      eventDate: json['event_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      timeTbd: _parseBool(json['time_tbd']),
      duration: _parseInt(json['duration']) ?? 0,
      location: json['location']?.toString() ?? '',
      locationDetails: json['location_details']?.toString(),
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      arrivalEarly: _parseInt(json['arrival_early']) ?? 0,
      trackAvailability: _parseBool(json['track_availability']),
      flagColor: json['flag_color']?.toString() ?? '',
      uniformColor: json['uniform_color']?.toString() ?? '',
      opponent: (json['opponant'] ?? json['opponent'])?.toString() ?? '',
      extraLabel: json['extra_label']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      status: _parseInt(json['status']) ?? 1,
      notificationEnabled: _parseBool(json['notification_enabled']),
      createdBy: _parseInt(json['created_by']),
      createdByType: json['created_by_type']?.toString(),
      updatedBy: _parseInt(json['updated_by']),
      updatedByType: json['updated_by_type']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value) {
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
