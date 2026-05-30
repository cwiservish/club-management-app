class ChatChannel {
  final int chatChannelId;
  final String uuid;
  final int clientId;
  final String name;
  final int channelType;
  final int isDefault;
  final int organizationId;
  final int teamId;
  final int createdById;
  final int createdByType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? teamName;
  final String? teamDivision;
  final String? teamLevel;
  final DateTime? leftAt;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final String? lastMessageText;
  final String permission;
  final int? memberCount;

  ChatChannel({
    required this.chatChannelId,
    required this.uuid,
    required this.clientId,
    required this.name,
    required this.channelType,
    required this.isDefault,
    required this.organizationId,
    required this.teamId,
    required this.createdById,
    required this.createdByType,
    this.createdAt,
    this.updatedAt,
    this.teamName,
    this.teamDivision,
    this.teamLevel,
    this.leftAt,
    required this.unreadCount,
    this.lastMessageAt,
    this.lastMessageText,
    required this.permission,
    this.memberCount,
  });

  factory ChatChannel.fromJson(Map<String, dynamic> json) {
    return ChatChannel(
      chatChannelId: _parseInt(json['chat_channel_id']),
      uuid: _parseString(json['uuid']),
      clientId: _parseInt(json['client_id']),
      name: _parseString(json['name']),
      channelType: _parseInt(json['channel_type']),
      isDefault: _parseInt(json['is_default']),
      organizationId: _parseInt(json['organization_id']),
      teamId: _parseInt(json['team_id']),
      createdById: _parseInt(json['created_by_id']),
      createdByType: _parseInt(json['created_by_type']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      teamName: _parseNullableString(json['team_name']),
      teamDivision: _parseNullableString(json['team_division']),
      teamLevel: _parseNullableString(json['team_level']),
      leftAt: _parseDateTime(json['left_at']),
      unreadCount: _parseInt(json['unread_count']),
      lastMessageAt: _parseDateTime(json['last_message_at']),
      lastMessageText: _parseNullableString(json['last_message_text']),
      permission: _parseString(json['permission'], defaultValue: 'Read'),
      memberCount: json['member_count'] != null ? _parseInt(json['member_count']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'chat_channel_id': chatChannelId,
        'uuid': uuid,
        'client_id': clientId,
        'name': name,
        'channel_type': channelType,
        'is_default': isDefault,
        'organization_id': organizationId,
        'team_id': teamId,
        'created_by_id': createdById,
        'created_by_type': createdByType,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'team_name': teamName,
        'team_division': teamDivision,
        'team_level': teamLevel,
        'left_at': leftAt?.toIso8601String(),
        'unread_count': unreadCount,
        'last_message_at': lastMessageAt?.toIso8601String(),
        'last_message_text': lastMessageText,
        'permission': permission,
        'member_count': memberCount,
      };

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static String _parseString(dynamic val, {String defaultValue = ''}) {
    if (val == null) return defaultValue;
    return val.toString();
  }

  static String? _parseNullableString(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    return str.isEmpty ? null : str;
  }

  static DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    return DateTime.tryParse(val.toString());
  }
}
