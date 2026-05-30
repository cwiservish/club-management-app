import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_channel.dart';
import '../models/chat_member.dart';
import '../models/chat_token.dart';

class ChatApiService {
  final ApiClient _apiClient;

  ChatApiService(this._apiClient);

  /// Fetches the TalkJS JWT session token, App ID, and User ID.
  Future<ChatTokenResponse> getChatToken() async {
    const endpoint = '/chat/member/token';

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] GET $endpoint');
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.get(endpoint);

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] GET $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    return ChatTokenResponse.fromJson(response.rawJson);
  }

  /// Fetches group channels for a given team.
  Future<List<ChatChannel>> fetchChannels(String teamUuid) async {
    const endpoint = '/chat/channel/list';
    final requestBody = {
      'team_uuid': teamUuid,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST $endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    final dataMap = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    final gridList = dataMap['grid'];
    if (gridList is List) {
      return gridList
          .map((c) => ChatChannel.fromJson(c is Map<String, dynamic> ? c : {}))
          .toList();
    }

    return [];
  }

  /// Fetches DMs / members available for a given team.
  Future<List<ChatMember>> fetchMembers(String teamUuid) async {
    const endpoint = '/chat/member/list';
    final requestBody = {
      'team_uuid': teamUuid,
      'isDm': 1,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST $endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    final dataMap = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    final gridList = dataMap['grid'];
    if (gridList is List) {
      return gridList
          .map((m) => ChatMember.fromJson(m is Map<String, dynamic> ? m : {}))
          .toList();
    }

    return [];
  }

  /// Searches for team members to add to a group channel (isDm = 0).
  Future<List<ChatMember>> searchChannelMembers(String teamUuid, String query) async {
    const endpoint = '/chat/member/list';
    final requestBody = {
      'team_uuid': teamUuid,
      'isDm': 0,
      'q': query,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST $endpoint (Search)');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint (Search)');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    final dataMap = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    final gridList = dataMap['grid'];
    if (gridList is List) {
      return gridList
          .map((m) => ChatMember.fromJson(m is Map<String, dynamic> ? m : {}))
          .toList();
    }

    return [];
  }

  /// Fetches existing members of a custom channel.
  Future<List<ChatMember>> fetchChannelExistingMembers(String teamUuid, int chatChannelId) async {
    const endpoint = '/chat/member/list';
    final requestBody = {
      'team_uuid': teamUuid,
      'chat_channel_id': chatChannelId,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST $endpoint (Existing Members)');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint (Existing Members)');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    final dataMap = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    final gridList = dataMap['grid'];
    if (gridList is List) {
      return gridList
          .map((m) => ChatMember.fromJson(m is Map<String, dynamic> ? m : {}))
          .toList();
    }

    return [];
  }

  /// Creates a new channel or edits an existing one.
  Future<bool> saveChannel({
    required String teamUuid,
    int? chatChannelId,
    required String name,
    required List<Map<String, dynamic>> users,
  }) async {
    const endpoint = '/chat/channel/save';
    final requestBody = {
      'team_uuid': teamUuid,
      if (chatChannelId != null) 'chat_channel_id': chatChannelId,
      'name': name,
      'users': users,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST $endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    return response.success;
  }

  /// Removes a custom channel.
  Future<bool> removeChannel(String teamUuid, int chatChannelId) async {
    const endpoint = '/chat/channel/remove';
    final requestBody = {
      'team_uuid': teamUuid,
      'chat_channel_id': chatChannelId,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST $endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    return response.success;
  }

  /// Removes a participant from a custom channel.
  Future<bool> removeMemberFromChannel(
    String teamUuid,
    int chatChannelId,
    int memberId,
    String memberType,
  ) async {
    const endpoint = '/chat/member/remove';
    final requestBody = {
      'team_uuid': teamUuid,
      'chat_channel_id': chatChannelId,
      'member_id': memberId,
      'member_type': memberType,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST $endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    return response.success;
  }
}
