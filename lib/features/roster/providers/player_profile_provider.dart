import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile_models.dart';
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
    state = state.copyWith(isLoading: true, errorMessage: null);
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
}

final playerProfileProvider =
    NotifierProvider.family<PlayerProfileNotifier, PlayerProfileState, String>(
  PlayerProfileNotifier.new,
);
