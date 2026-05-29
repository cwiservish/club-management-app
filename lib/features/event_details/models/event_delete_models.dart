class EventDeleteRequest {
  final String teamUuid;
  final dynamic id; // dynamic to safely handle both String and int IDs

  EventDeleteRequest({
    required this.teamUuid,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
    'team_uuid': teamUuid,
    'id': id,
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
