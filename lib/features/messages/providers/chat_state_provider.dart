import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_channel.dart';
import '../models/chat_member.dart';
import '../models/chat_token.dart';
import '../services/chat_api_service.dart';

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
  return await service.searchChannelMembers(arg.teamUuid, arg.query);
});

/// Future provider fetching existing members of a specific channel
final chatChannelMembersProvider = FutureProvider.family<List<ChatMember>, ({String teamUuid, int chatChannelId})>((ref, arg) async {
  if (arg.teamUuid.isEmpty) return [];
  final service = ref.watch(chatApiServiceProvider);
  return await service.fetchChannelExistingMembers(arg.teamUuid, arg.chatChannelId);
});

