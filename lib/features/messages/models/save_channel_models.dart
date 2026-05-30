import 'chat_channel.dart';

class SaveChannelRequest {
  final String teamUuid;
  final String name;
  final List<SaveChannelUser> users;
  final int? chatChannelId;

  SaveChannelRequest({
    required this.teamUuid,
    required this.name,
    required this.users,
    this.chatChannelId,
  });

  Map<String, dynamic> toJson() => {
        'team_uuid': teamUuid,
        'name': name,
        'users': users.map((u) => u.toJson()).toList(),
        if (chatChannelId != null) 'id': chatChannelId,
      };
}

class SaveChannelUser {
  final int memberId;
  final String memberType;

  SaveChannelUser({
    required this.memberId,
    required this.memberType,
  });

  Map<String, dynamic> toJson() => {
        'member_id': memberId,
        'member_type': memberType,
      };
}

class SaveChannelResponse {
  final bool success;
  final String message;
  final ChatChannel? channel;

  SaveChannelResponse({
    required this.success,
    required this.message,
    this.channel,
  });

  factory SaveChannelResponse.fromJson(Map<String, dynamic> json) {
    return SaveChannelResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      channel: json['channel'] != null && json['channel'] is Map<String, dynamic>
          ? ChatChannel.fromJson(json['channel'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (channel != null) 'channel': channel!.toJson(),
      };
}
