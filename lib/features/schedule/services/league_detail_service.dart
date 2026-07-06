import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/league_detail_models.dart';

class LeagueDetailService {
  const LeagueDetailService(this._apiClient);

  final ApiClient _apiClient;

  Future<LeagueDetailResult> fetchLeagueDetail({
    required String teamUuid,
    required int eventDbId,
    required int schedulingMode,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.eventDetail,
      body: {
        'team_uuid': teamUuid,
        'scheduling_mode': schedulingMode,
        'id': eventDbId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final rawSessions = data['child_sessions'] as List? ?? [];
    final childSessions = rawSessions.whereType<Map<String, dynamic>>().toList();

    return LeagueDetailResult(childSessions: childSessions);
  }
}

final leagueDetailServiceProvider = Provider<LeagueDetailService>(
  (ref) => LeagueDetailService(ref.read(apiClientProvider)),
);
