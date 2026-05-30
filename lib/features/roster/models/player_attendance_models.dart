class PlayerAttendanceEvent {
  final int id;
  final int teamEventId;
  final String uuid;
  final int? scheduleGameId;
  final String eventName;
  final String eventDate;
  final String dateLabel;
  final String startTime;
  final String endTime;
  final String timeLabel;
  final String location;
  final String locationDetails;
  final String? opponent;
  final String? extraLabel;
  final int? teamEventAttendeeId;
  final int? attendance;
  final String attendanceNotes;

  PlayerAttendanceEvent({
    required this.id,
    required this.teamEventId,
    required this.uuid,
    this.scheduleGameId,
    required this.eventName,
    required this.eventDate,
    required this.dateLabel,
    required this.startTime,
    required this.endTime,
    required this.timeLabel,
    required this.location,
    required this.locationDetails,
    this.opponent,
    this.extraLabel,
    this.teamEventAttendeeId,
    this.attendance,
    required this.attendanceNotes,
  });

  factory PlayerAttendanceEvent.fromJson(Map<String, dynamic> json) {
    return PlayerAttendanceEvent(
      id: _parseInt(json['id']),
      teamEventId: _parseInt(json['team_event_id']),
      uuid: json['uuid']?.toString() ?? '',
      scheduleGameId: json['schedule_game_id'] != null ? _parseInt(json['schedule_game_id']) : null,
      eventName: json['event_name']?.toString() ?? '',
      eventDate: json['event_date']?.toString() ?? '',
      dateLabel: json['date_label']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      timeLabel: json['time_label']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      locationDetails: json['location_details']?.toString() ?? '',
      opponent: json['opponant']?.toString() ?? json['opponent']?.toString(), // Handle potential typo "opponant" from response
      extraLabel: json['extra_label']?.toString(),
      teamEventAttendeeId: json['team_event_attendee_id'] != null ? _parseInt(json['team_event_attendee_id']) : null,
      attendance: json['attendance'] != null ? _parseInt(json['attendance']) : null,
      attendanceNotes: json['attendance_notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'team_event_id': teamEventId,
        'uuid': uuid,
        if (scheduleGameId != null) 'schedule_game_id': scheduleGameId,
        'event_name': eventName,
        'event_date': eventDate,
        'date_label': dateLabel,
        'start_time': startTime,
        'end_time': endTime,
        'time_label': timeLabel,
        'location': location,
        'location_details': locationDetails,
        if (opponent != null) 'opponant': opponent,
        if (extraLabel != null) 'extra_label': extraLabel,
        if (teamEventAttendeeId != null) 'team_event_attendee_id': teamEventAttendeeId,
        if (attendance != null) 'attendance': attendance,
        'attendance_notes': attendanceNotes,
      };

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}

class PlayerAttendanceData {
  final List<PlayerAttendanceEvent> grid;
  final int total;

  PlayerAttendanceData({
    required this.grid,
    required this.total,
  });

  factory PlayerAttendanceData.fromJson(Map<String, dynamic> json) {
    final gridList = json['grid'];
    List<PlayerAttendanceEvent> parsedGrid = [];
    if (gridList is List) {
      parsedGrid = gridList
          .map((item) => PlayerAttendanceEvent.fromJson(item is Map<String, dynamic> ? item : {}))
          .toList();
    }
    return PlayerAttendanceData(
      grid: parsedGrid,
      total: json['total'] as int? ?? parsedGrid.length,
    );
  }

  Map<String, dynamic> toJson() => {
        'grid': grid.map((e) => e.toJson()).toList(),
        'total': total,
      };
}

class PlayerAttendanceHistoryResponse {
  final bool success;
  final String message;
  final PlayerAttendanceData? data;

  PlayerAttendanceHistoryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PlayerAttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PlayerAttendanceHistoryResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? PlayerAttendanceData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}
