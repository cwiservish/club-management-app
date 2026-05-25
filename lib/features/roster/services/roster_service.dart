import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/players_list_models.dart';
import '../models/roster_member.dart';
import '../../../core/models/sample_data.dart';

class RosterService {
  final ApiClient _apiClient;

  RosterService(this._apiClient);

  List<RosterMember> getMembers() => sampleRoster;

  /// Fetches players for a given team from the API.
  Future<PlayersListResponse> fetchPlayers(String teamUuid) async {
    final response = await _apiClient.post(
      ApiEndpoints.teamPlayersList(teamUuid),
      body: {}, // empty body as specified in the curl/postman request
    );

    final dataMap = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    return PlayersListResponse(
      success: response.success,
      message: response.message ?? '',
      data: PlayersListData.fromJson(dataMap),
    );
  }
}
