class ChatTokenResponse {
  final bool success;
  final String message;
  final String token;
  final String appId;
  final String userId;

  ChatTokenResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.appId,
    required this.userId,
  });

  factory ChatTokenResponse.fromJson(Map<String, dynamic> json) {
    return ChatTokenResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      token: json['token'] as String? ?? '',
      appId: json['app_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'token': token,
        'app_id': appId,
        'user_id': userId,
      };
}
