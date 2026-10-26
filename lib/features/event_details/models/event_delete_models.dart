class EventDeleteRequest {
  final String teamUuid;
  final dynamic id; // dynamic to safely handle both String and int IDs
  final int schedulingMode;

  /// Series code: delete every upcoming date of the series instead of one `id`.
  final String? code;

  EventDeleteRequest({
    required this.teamUuid,
    required this.id,
    required this.schedulingMode,
    this.code,
  });

  Map<String, dynamic> toJson() => {
    'team_uuid': teamUuid,
    if (code != null && code!.isNotEmpty) 'code': code else 'id': id,
    'scheduling_mode': schedulingMode,
  };
}

class EventDeleteResponse {
  final bool success;
  final String message;

  EventDeleteResponse({
    required this.success,
    required this.message,
  });

  factory EventDeleteResponse.fromJson(Map<String, dynamic> json) {
    return EventDeleteResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}
