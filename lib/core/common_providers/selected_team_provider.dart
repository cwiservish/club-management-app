import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team_model.dart';
import 'user_teams_provider.dart';

/// Global Riverpod notifier to manage and synchronize the selected team across the app.
class SelectedTeamNotifier extends Notifier<Team?> {
  @override
  Team? build() {
    final teamsAsync = ref.watch(userTeamsProvider);
    return teamsAsync.maybeWhen(
      data: (list) => list.isNotEmpty ? list.first : null,
      orElse: () => null,
    );
  }

  void selectTeam(Team team) {
    state = team;
  }
}

final selectedTeamProvider = NotifierProvider<SelectedTeamNotifier, Team?>(
  SelectedTeamNotifier.new,
);
