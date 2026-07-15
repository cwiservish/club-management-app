import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile_models.dart';
import '../models/assign_parent_models.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import 'roster_provider.dart';

class PlayerProfileState {
  final bool isLoading;
  final String? errorMessage;
  final PlayerProfileResponse? profile;

  const PlayerProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.profile,
  });

  PlayerProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    PlayerProfileResponse? profile,
  }) {
    return PlayerProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      profile: profile ?? this.profile,
    );
  }
}

class PlayerProfileNotifier extends Notifier<PlayerProfileState> {
  final String playerUuid;
  PlayerProfileNotifier(this.playerUuid);

  @override
  PlayerProfileState build() {
    // Start fetching profile
    final activeTeam = ref.watch(selectedTeamProvider);
    if (activeTeam != null) {
      Future.microtask(() => fetchProfile(activeTeam.uuid, playerUuid));
    }
    return const PlayerProfileState(isLoading: true);
  }

  Future<void> fetchProfile(String teamUuid, String playerUuid) async {
    state = state.copyWith(isLoading: true, errorMessage: null, profile: null);
    try {
      final response = await ref.read(rosterServiceProvider).fetchPlayerProfile(teamUuid, playerUuid);
      state = state.copyWith(
        isLoading: false,
        profile: response,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam != null) {
      await fetchProfile(activeTeam.uuid, playerUuid);
    }
  }

  /// Assigns a family member to the current player
  Future<AssignParentResponse> assignParent(String email) async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam == null) {
      throw 'No team selected';
    }

    final response = await ref.read(rosterServiceProvider).assignParent(
          teamUuid: activeTeam.uuid,
          playerUuid: playerUuid,
          organizationId: activeTeam.organizationId.toString(),
          email: email,
        );

    // If API returns updated parent list, update local state
    if (response.data != null) {
      final updatedParents = response.data!.parents;
      if (state.profile != null) {
        final updatedProfile = PlayerProfileResponse(
          success: state.profile!.success,
          message: state.profile!.message,
          data: PlayerProfileData(
            player: state.profile!.data.player,
            parents: updatedParents,
          ),
        );
        state = state.copyWith(profile: updatedProfile);
      } else {
        await refresh();
      }
    }

    return response;
  }
}

final playerProfileProvider =
    NotifierProvider.autoDispose.family<PlayerProfileNotifier, PlayerProfileState, String>(
  PlayerProfileNotifier.new,
);
