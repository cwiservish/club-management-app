import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/players_list_models.dart';
import '../models/player_profile_models.dart';
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

  /// Fetches player profile details from the API.
  Future<PlayerProfileResponse> fetchPlayerProfile(String teamUuid, String playerUuid) async {
    final endpoint = ApiEndpoints.playerProfile(teamUuid, playerUuid);
    final requestBody = <String, dynamic>{};

    // Print Request JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    final dataMap = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    // Construct response map for printing
    final rawResponseMap = {
      'success': response.success,
      'message': response.message ?? '',
      'data': response.data,
    };

    // Print Response JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
    debugPrint('════════════════════════════════════════════════════════════════');

    return PlayerProfileResponse(
      success: response.success,
      message: response.message ?? '',
      data: PlayerProfileData.fromJson(dataMap),
    );
  }
}
