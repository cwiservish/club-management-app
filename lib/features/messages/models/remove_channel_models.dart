class RemoveChannelRequest {
  final String teamUuid;
  final int id;

  RemoveChannelRequest({
    required this.teamUuid,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        'team_uuid': teamUuid,
        'id': id,
      };
}

class RemoveChannelResponse {
  final bool success;
  final String message;

  RemoveChannelResponse({
    required this.success,
    required this.message,
  });

  factory RemoveChannelResponse.fromJson(Map<String, dynamic> json) {
    return RemoveChannelResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
      };
}
