import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../models/league_detail_models.dart';
import '../services/league_detail_service.dart';

final leagueDetailProvider =
    FutureProvider.family<LeagueDetailResult, LeagueDetailArgs>(
  (ref, args) {
    final teamUuid = ref.read(selectedTeamProvider)?.uuid ?? '';
    return ref.read(leagueDetailServiceProvider).fetchLeagueDetail(
          teamUuid: teamUuid,
          eventDbId: args.eventDbId,
          schedulingMode: args.schedulingMode,
        );
  },
);
