class PlayerAttendanceEvent {
  final int id;
  final int teamEventSessionId;
  final String uuid;
  final int? scheduleGameId;
  final String eventName;
  final String displayName;
  final String eventDate;
  final String dateLabel;
  final String startTime;
  final String endTime;
  final String timeLabel;
  final String location;
  final String locationDetails;
  final String opponentTeamName;
  final int? teamEventAttendeeId;
  final int? attendance;
  final String attendanceNotes;

  PlayerAttendanceEvent({
    required this.id,
    required this.teamEventSessionId,
    required this.uuid,
    this.scheduleGameId,
    required this.eventName,
    required this.displayName,
    required this.eventDate,
    required this.dateLabel,
    required this.startTime,
    required this.endTime,
    required this.timeLabel,
    required this.location,
    required this.locationDetails,
    required this.opponentTeamName,
    this.teamEventAttendeeId,
    this.attendance,
    required this.attendanceNotes,
  });

  factory PlayerAttendanceEvent.fromJson(Map<String, dynamic> json) {
    return PlayerAttendanceEvent(
      id: _parseInt(json['id']),
      teamEventSessionId: _parseInt(json['team_event_session_id']),
      uuid: json['uuid']?.toString() ?? '',
      scheduleGameId: json['schedule_game_id'] != null ? _parseInt(json['schedule_game_id']) : null,
      eventName: json['event_name']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? json['name']?.toString() ?? '',
      eventDate: json['event_date']?.toString() ?? json['session_date']?.toString() ?? '',
      dateLabel: json['date_label']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      timeLabel: json['time_label']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      locationDetails: json['location_details']?.toString() ?? '',
      opponentTeamName: json['opponent_team_name']?.toString() ?? '',
      teamEventAttendeeId: json['team_event_session_attendee_id'] != null
          ? _parseInt(json['team_event_session_attendee_id'])
          : null,
      attendance: json['attendance'] != null ? _parseInt(json['attendance']) : null,
      attendanceNotes: json['attendance_notes']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}

class PlayerAttendancePagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool isLastPage;

  PlayerAttendancePagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.isLastPage,
  });

  factory PlayerAttendancePagination.fromJson(Map<String, dynamic> json) {
    return PlayerAttendancePagination(
      total: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 50,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      isLastPage: json['is_last_page'] as bool? ?? true,
    );
  }
}

class PlayerAttendanceData {
  final List<PlayerAttendanceEvent> items;
  final int total;
  final PlayerAttendancePagination pagination;

  PlayerAttendanceData({
    required this.items,
    required this.total,
    required this.pagination,
  });

  factory PlayerAttendanceData.fromJson(Map<String, dynamic> json) {
    // Use 'items' list; fall back to 'grid' if items is absent
    final rawList = (json['items'] is List ? json['items'] : json['grid']) as List? ?? [];
    final parsedItems = rawList
        .map((item) => PlayerAttendanceEvent.fromJson(item is Map<String, dynamic> ? item : {}))
        .toList();

    final paginationJson = json['pagination'];
    final pagination = paginationJson is Map<String, dynamic>
        ? PlayerAttendancePagination.fromJson(paginationJson)
        : PlayerAttendancePagination(
            total: json['total'] as int? ?? parsedItems.length,
            perPage: 50,
            currentPage: 1,
            lastPage: 1,
            isLastPage: true,
          );

    return PlayerAttendanceData(
      items: parsedItems,
      total: json['total'] as int? ?? parsedItems.length,
      pagination: pagination,
    );
  }
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
}
