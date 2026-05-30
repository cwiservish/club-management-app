import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_storage/app_storage.dart';
import '../models/team_model.dart';
import 'user_teams_provider.dart';

/// Global Riverpod notifier to manage and synchronize the selected team across the app.
class SelectedTeamNotifier extends Notifier<Team?> {
  static String? _selectedTeamUuid;

  static void setInitialUuid(String uuid) {
    _selectedTeamUuid = uuid;
  }

  @override
  Team? build() {
    final teamsAsync = ref.watch(userTeamsProvider);

    // If memory cache is empty, load it from AppStorage asynchronously.
    if (_selectedTeamUuid == null) {
      _loadSavedTeamUuid();
    }

    final list = teamsAsync.value;
    if (list != null && list.isNotEmpty) {
      if (_selectedTeamUuid != null) {
        final found = list.firstWhere(
          (t) => t.uuid == _selectedTeamUuid,
          orElse: () => list.first,
        );
        return found;
      }
      return list.first;
    }
    return null;
  }

  Future<void> _loadSavedTeamUuid() async {
    try {
      final savedUuid = await ref.read(appStorageProvider).readSelectedTeamUuid();
      if (savedUuid != null && _selectedTeamUuid == null) {
        _selectedTeamUuid = savedUuid;
        // Re-read userTeamsProvider state to update selection if needed.
        final teamsAsync = ref.read(userTeamsProvider);
        teamsAsync.whenData((list) {
          if (list.isNotEmpty) {
            final found = list.firstWhere(
              (t) => t.uuid == _selectedTeamUuid,
              orElse: () => list.first,
            );
            state = found;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading saved team UUID: $e');
    }
  }

  void selectTeam(Team team) {
    _selectedTeamUuid = team.uuid;
    ref.read(appStorageProvider).saveSelectedTeamUuid(team.uuid);
    state = team;
  }

  void clearSelectedTeam() {
    _selectedTeamUuid = null;
    state = null;
  }
}

final selectedTeamProvider = NotifierProvider<SelectedTeamNotifier, Team?>(
  SelectedTeamNotifier.new,
);
