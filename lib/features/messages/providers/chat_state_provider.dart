import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talkjs_flutter/talkjs_flutter.dart' hide Provider;
import '../../../core/common_providers/current_user_provider.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_channel.dart';
import '../models/chat_member.dart';
import '../models/chat_token.dart';
import '../services/chat_api_service.dart';
import '../models/member_list_models.dart';

/// Provider for ChatApiService
final chatApiServiceProvider = Provider<ChatApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatApiService(apiClient);
});

/// Future provider caching the TalkJS token response.
final chatTokenProvider = FutureProvider<ChatTokenResponse>((ref) async {
  final service = ref.watch(chatApiServiceProvider);
  return await service.getChatToken();
});

/// Future provider retrieving list of channels for a team.
final chatChannelsProvider = FutureProvider.family<List<ChatChannel>, String>((ref, teamUuid) async {
  if (teamUuid.isEmpty) return [];
  final service = ref.watch(chatApiServiceProvider);
  return await service.fetchChannels(teamUuid);
});

/// Future provider retrieving DMs / list of members for a team.
final chatMembersProvider = FutureProvider.family<List<ChatMember>, String>((ref, teamUuid) async {
  if (teamUuid.isEmpty) return [];
  final service = ref.watch(chatApiServiceProvider);
  return await service.fetchMembers(teamUuid);
});

/// Notifier and provider for active search input query.
class ChatSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String val) => state = val;
}

final chatSearchQueryProvider = NotifierProvider<ChatSearchQueryNotifier, String>(
  ChatSearchQueryNotifier.new,
);

/// Notifier and provider for toggling between "Channels" (index 0) and "Direct Messages" (index 1).
class ChatActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int val) => state = val;
}

final chatActiveTabProvider = NotifierProvider<ChatActiveTabNotifier, int>(
  ChatActiveTabNotifier.new,
);

/// Future provider retrieving channel members by search query
final chatSearchMembersProvider = FutureProvider.family<List<ChatMember>, ({String teamUuid, String query})>((ref, arg) async {
  if (arg.teamUuid.isEmpty || arg.query.length < 3) return [];
  final service = ref.watch(chatApiServiceProvider);
  final response = await service.searchChannelMembers(MemberListRequest(
    teamUuid: arg.teamUuid,
    isDm: 0,
    q: arg.query,
  ));
  return response.data?.grid ?? [];
});

/// Future provider retrieving DM members by search query (isDm = 1)
final chatSearchDmsProvider = FutureProvider.family<List<ChatMember>, ({String teamUuid, String query})>((ref, arg) async {
  if (arg.teamUuid.isEmpty || arg.query.length < 3) return [];
  final service = ref.watch(chatApiServiceProvider);
  final response = await service.searchChannelMembers(MemberListRequest(
    teamUuid: arg.teamUuid,
    isDm: 1,
    q: arg.query,
  ));
  return response.data?.grid ?? [];
});

/// Future provider fetching existing members of a specific channel
final chatChannelMembersProvider = FutureProvider.family<List<ChatMember>, ({String teamUuid, int chatChannelId})>((ref, arg) async {
  if (arg.teamUuid.isEmpty) return [];
  final service = ref.watch(chatApiServiceProvider);
  final response = await service.fetchChannelExistingMembers(MemberListRequest(
    teamUuid: arg.teamUuid,
    chatChannelId: arg.chatChannelId,
  ));
  return response.data?.grid ?? [];
});

String _getJwtSub(String jwtToken) {
  try {
    final parts = jwtToken.split('.');
    if (parts.length >= 2) {
      String payload = parts[1];
      final padding = 4 - (payload.length % 4);
      if (padding > 0 && padding < 4) payload += '=' * padding;
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      final map = json.decode(utf8.decode(base64.decode(payload)));
      return map['sub']?.toString() ?? '';
    }
  } catch (e) {
    debugPrint('Error parsing JWT: $e');
  }
  return '';
}

final talkJsSessionProvider = Provider<Session?>((ref) {
  final tokenAsync = ref.watch(chatTokenProvider);
  final userAsync = ref.watch(currentUserProvider);

  final tokenResponse = tokenAsync.asData?.value;
  final currentUser = userAsync.asData?.value;

  if (tokenResponse == null || currentUser == null) return null;

  final session = Session(
    appId: tokenResponse.appId,
    token: tokenResponse.token,
    onMessage: (message) {
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[TalkJS Event] Live message received: ${message.body}');
      debugPrint('════════════════════════════════════════════════════════════════');
      final activeTeam = ref.read(selectedTeamProvider);
      if (activeTeam != null) {
        ref.invalidate(chatChannelsProvider(activeTeam.uuid));
        ref.invalidate(chatMembersProvider(activeTeam.uuid));
      }
    },
  );

  final jwtSub = _getJwtSub(tokenResponse.token);
  final talkJsUserId = jwtSub.isNotEmpty ? jwtSub : tokenResponse.userId;

  final me = session.getUser(
    id: talkJsUserId,
    name: currentUser.displayName,
    email: [talkJsUserId],
  );
  session.me = me;

  return session;
});

