import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_member.dart';
import '../models/save_channel_models.dart';
import '../services/chat_api_service.dart';
import 'chat_state_provider.dart';

class CreateChannelState {
  final String channelName;
  final int currentStep;
  final String searchQuery;
  final List<ChatMember> selectedMembers;
  final bool isSaving;

  const CreateChannelState({
    required this.channelName,
    required this.currentStep,
    required this.searchQuery,
    required this.selectedMembers,
    required this.isSaving,
  });

  CreateChannelState copyWith({
    String? channelName,
    int? currentStep,
    String? searchQuery,
    List<ChatMember>? selectedMembers,
    bool? isSaving,
  }) {
    return CreateChannelState(
      channelName: channelName ?? this.channelName,
      currentStep: currentStep ?? this.currentStep,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class CreateChannelNotifier extends Notifier<CreateChannelState> {
  @override
  CreateChannelState build() {
    return const CreateChannelState(
      channelName: '',
      currentStep: 0,
      searchQuery: '',
      selectedMembers: [],
      isSaving: false,
    );
  }

  void setChannelName(String name) {
    state = state.copyWith(channelName: name);
  }

  void nextStep() {
    state = state.copyWith(currentStep: 1);
  }

  void prevStep() {
    state = state.copyWith(currentStep: 0);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleMemberSelection(ChatMember member) {
    final list = List<ChatMember>.from(state.selectedMembers);
    final exists = list.any((m) => m.memberId == member.memberId && m.memberType == member.memberType);
    if (exists) {
      list.removeWhere((m) => m.memberId == member.memberId && m.memberType == member.memberType);
    } else {
      list.add(member);
    }
    state = state.copyWith(selectedMembers: list);
  }

  Future<SaveChannelResponse> saveChannel(String teamUuid) async {
    state = state.copyWith(isSaving: true);
    try {
      final service = ref.read(chatApiServiceProvider);
      final usersPayload = state.selectedMembers
          .map((m) => SaveChannelUser(
                memberId: m.memberId,
                memberType: m.memberType,
              ))
          .toList();

      final request = SaveChannelRequest(
        teamUuid: teamUuid,
        name: state.channelName,
        users: usersPayload,
      );

      final response = await service.saveChannel(request);
      if (response.success) {
        // Invalidate channel list to trigger re-fetch on Messages Page
        ref.invalidate(chatChannelsProvider(teamUuid));
      }
      return response;
    } catch (e) {
      return SaveChannelResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final createChannelViewModelProvider =
    NotifierProvider.autoDispose<CreateChannelNotifier, CreateChannelState>(
  CreateChannelNotifier.new,
);
