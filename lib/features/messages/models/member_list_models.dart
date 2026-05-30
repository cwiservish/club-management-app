import 'chat_member.dart';

class MemberListRequest {
  final String teamUuid;
  final int? isDm;
  final String? q;
  final int? chatChannelId;

  MemberListRequest({
    required this.teamUuid,
    this.isDm,
    this.q,
    this.chatChannelId,
  });

  Map<String, dynamic> toJson() => {
        'team_uuid': teamUuid,
        if (isDm != null) 'isDm': isDm,
        if (q != null) 'q': q,
        if (chatChannelId != null) 'chat_channel_id': chatChannelId,
      };
}

class MemberListResponse {
  final bool success;
  final String message;
  final MemberListData? data;

  MemberListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MemberListResponse.fromJson(Map<String, dynamic> json) {
    return MemberListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? MemberListData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}

class MemberListData {
  final List<ChatMember> grid;
  final int total;

  MemberListData({
    required this.grid,
    required this.total,
  });

  factory MemberListData.fromJson(Map<String, dynamic> json) {
    final gridList = json['grid'];
    List<ChatMember> parsedGrid = [];
    if (gridList is List) {
      parsedGrid = gridList
          .map((m) => ChatMember.fromJson(m is Map<String, dynamic> ? m : {}))
          .toList();
    }
    return MemberListData(
      grid: parsedGrid,
      total: json['total'] as int? ?? parsedGrid.length,
    );
  }

  Map<String, dynamic> toJson() => {
        'grid': grid.map((m) => m.toJson()).toList(),
        'total': total,
      };
}
