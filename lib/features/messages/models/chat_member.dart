class ChatMember {
  final String uuid;
  final String email;
  final String name;
  final String memberUuid;
  final int memberId;
  final String memberType;
  final int? chatChannelId;
  final String permissions;
  final int status;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final String? lastMessageText;

  ChatMember({
    required this.uuid,
    required this.email,
    required this.name,
    required this.memberUuid,
    required this.memberId,
    required this.memberType,
    this.chatChannelId,
    required this.permissions,
    required this.status,
    required this.unreadCount,
    this.lastMessageAt,
    this.lastMessageText,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      uuid: _parseString(json['uuid']),
      email: _parseString(json['email']),
      name: _parseString(json['name']),
      memberUuid: _parseString(json['member_uuid']),
      memberId: _parseInt(json['member_id']),
      memberType: _parseString(json['member_type']),
      chatChannelId: json['chat_channel_id'] != null ? _parseInt(json['chat_channel_id']) : null,
      permissions: _parseString(json['permissions'], defaultValue: 'ReadWrite'),
      status: _parseInt(json['status']),
      unreadCount: _parseInt(json['unread_count']),
      lastMessageAt: _parseDateTime(json['last_message_at']),
      lastMessageText: _parseNullableString(json['last_message_text']),
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'email': email,
        'name': name,
        'member_uuid': memberUuid,
        'member_id': memberId,
        'member_type': memberType,
        'chat_channel_id': chatChannelId,
        'permissions': permissions,
        'status': status,
        'unread_count': unreadCount,
        'last_message_at': lastMessageAt?.toIso8601String(),
        'last_message_text': lastMessageText,
      };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

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
