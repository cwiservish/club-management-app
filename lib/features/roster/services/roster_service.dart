import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/exceptions/network_exception.dart';
import '../models/players_list_models.dart';
import '../models/staff_list_models.dart';
import '../models/player_profile_models.dart';
import '../models/assign_parent_models.dart';
import '../models/roster_member.dart';
import '../models/player_positions_models.dart';
import '../../../core/models/sample_data.dart';

class RosterService {
  final ApiClient _apiClient;

  RosterService(this._apiClient);

  List<RosterMember> getMembers() => sampleRoster;

  /// Fetches players for a given team from the API.
  Future<PlayersListResponse> fetchPlayers(String teamUuid) async {
    final requestBody = {
      'team_uuid': teamUuid,
    };

    // Print Request JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.teamPlayersList}');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      ApiEndpoints.teamPlayersList,
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
    debugPrint('[API Response] POST ${ApiEndpoints.teamPlayersList}');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
    debugPrint('════════════════════════════════════════════════════════════════');

    return PlayersListResponse(
      success: response.success,
      message: response.message ?? '',
      data: PlayersListData.fromJson(dataMap),
    );
  }

  /// Fetches staff members for a given team from the API.
  Future<StaffListResponse> fetchStaff(String teamUuid) async {
    final requestBody = StaffListRequest(teamUuid: teamUuid).toJson();

    // Print Request JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.teamStaffList}');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      ApiEndpoints.teamStaffList,
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
    debugPrint('[API Response] POST ${ApiEndpoints.teamStaffList}');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(rawResponseMap));
    debugPrint('════════════════════════════════════════════════════════════════');

    return StaffListResponse(
      success: response.success,
      message: response.message ?? '',
      data: StaffListData.fromJson(dataMap),
    );
  }

  /// Fetches player profile details from the API.
  Future<PlayerProfileResponse> fetchPlayerProfile(String teamUuid, String playerUuid) async {
    const endpoint = ApiEndpoints.playerProfile;
    final requestBody = {
      'team_uuid': teamUuid,
      'player_uuid': playerUuid,
    };

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

  /// Assigns / invites a family member (parent) to a player.
  Future<AssignParentResponse> assignParent({
    required String teamUuid,
    required String playerUuid,
    required String organizationId,
    required String email,
  }) async {
    const endpoint = ApiEndpoints.assignParent;
    final requestBody = AssignParentRequest(
      teamUuid: teamUuid,
      playerUuid: playerUuid,
      organizationId: organizationId,
      email: email,
    ).toJson();

    // Print Request JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    try {
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

      return AssignParentResponse(
        success: response.success,
        message: response.message ?? '',
        data: AssignParentData.fromJson(dataMap),
      );
    } catch (e) {
      Map<String, dynamic>? errorData;
      String? errorMessage;
      bool success = false;

      if (e is DioException) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorData = responseData;
          success = responseData['success'] == true;
          errorMessage = responseData['message']?.toString();
        }
      } else if (e is NetworkException) {
        errorMessage = e.message;
      }

      if (errorData != null) {
        // Print Error Response JSON in logs if present
        debugPrint('════════════════════════════════════════════════════════════════');
        debugPrint('[API Response Error Body] POST $endpoint');
        debugPrint(const JsonEncoder.withIndent('  ').convert(errorData));
        debugPrint('════════════════════════════════════════════════════════════════');

        final dataMap = errorData['data'] is Map<String, dynamic>
            ? errorData['data'] as Map<String, dynamic>
            : <String, dynamic>{};

        return AssignParentResponse(
          success: success,
          message: errorMessage ?? 'Something went wrong',
          data: AssignParentData.fromJson(dataMap),
        );
      }

      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('[API Request Error] POST $endpoint: $e');
      debugPrint('════════════════════════════════════════════════════════════════');

      return AssignParentResponse(
        success: false,
        message: e is NetworkException ? e.message : e.toString(),
      );
    }
  }

  /// Fetches the player positions from the API.
  Future<PlayerPositionsResponse> fetchPlayerPositions(String teamUuid) async {
    const endpoint = ApiEndpoints.playerPositions;
    final requestBody = {
      'team_uuid': teamUuid,
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    // Print Response JSON in logs
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    return PlayerPositionsResponse.fromJson(response.rawJson);
  }

  /// Saves a new player to a team.
  Future<ApiResponse> savePlayer({
    required String teamUuid,
    required String firstName,
    required String lastName,
    required String jersey,
    required int primaryPosition,
    String? imageBase64,
  }) async {
    const endpoint = ApiEndpoints.playerSave;
    final requestBody = {
      'team_uuid': teamUuid,
      'players': [
        {
          'first_name': firstName,
          'last_name': lastName,
          'jersey': jersey,
          'primary_position': primaryPosition,
          if (imageBase64 != null) 'image': imageBase64,
        }
      ]
    };

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Request] POST ${ApiEndpoints.baseUrl}$endpoint');
    debugPrint('[API Request Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
    debugPrint('════════════════════════════════════════════════════════════════');

    final response = await _apiClient.post(
      endpoint,
      body: requestBody,
    );

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[API Response] POST $endpoint');
    debugPrint('[API Response Body]:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(response.rawJson));
    debugPrint('════════════════════════════════════════════════════════════════');

    return response;
  }
}
