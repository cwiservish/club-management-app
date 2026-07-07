class EventDeleteRequest {
  final String teamUuid;
  final dynamic id; // dynamic to safely handle both String and int IDs
  final int schedulingMode;

  EventDeleteRequest({
    required this.teamUuid,
    required this.id,
    required this.schedulingMode,
  });

  Map<String, dynamic> toJson() => {
    'team_uuid': teamUuid,
    'id': id,
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
