// ─── Shared Crash-Proof Parsing Helpers ────────────────────────────────────────

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _parseString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
  }
  return false;
}

// ─── Models ───────────────────────────────────────────────────────────────────

class PlayersListRequest {
  final String? search;
  final int? page;
  final int? limit;

  const PlayersListRequest({
    this.search,
    this.page,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      if (search != null) 'search': search,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
  }
}

class PlayersListResponse {
  final bool success;
  final String message;
  final PlayersListData data;

  const PlayersListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PlayersListResponse.fromJson(Map<String, dynamic> json) {
    return PlayersListResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: PlayersListData.fromJson(
        json['data'] is Map<String, dynamic> ? json['data'] : {},
      ),
    );
  }
}

class PlayersListData {
  final List<PlayerModel> grid;
  final int total;

  const PlayersListData({
    required this.grid,
    required this.total,
  });

  factory PlayersListData.fromJson(Map<String, dynamic> json) {
    final list = json['grid'] as List?;
    return PlayersListData(
      grid: list
              ?.map((e) => PlayerModel.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
      total: _parseInt(json['total']),
    );
  }
}

class PlayerModel {
  final int teamPlayerId;
  final int playerId;
  final String uuid;
  final String firstName;
  final String lastName;
  final String name;
  final String dateOfBirth;
  final String gender;
  final int heightFeet;
  final int heightInches;
  final int heightTotalInches;
  final String jerseyNo;
  final String imageUrl;
  final String profileImageUrl;
  final String profileUrl;
  final String parentVerified;
  final String parentRegistered;
  final String guest;
  final String location;
  final String gradYear;
  final String primaryPosition;
  final String otherPositions;

  const PlayerModel({
    required this.teamPlayerId,
    required this.playerId,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.heightFeet,
    required this.heightInches,
    required this.heightTotalInches,
    required this.jerseyNo,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.profileUrl,
    required this.parentVerified,
    required this.parentRegistered,
    required this.guest,
    required this.location,
    required this.gradYear,
    required this.primaryPosition,
    required this.otherPositions,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      teamPlayerId: _parseInt(json['team_player_id']),
      playerId: _parseInt(json['player_id']),
      uuid: _parseString(json['uuid']),
      firstName: _parseString(json['first_name']),
      lastName: _parseString(json['last_name']),
      name: _parseString(json['name']),
      dateOfBirth: _parseString(json['date_of_birth']),
      gender: _parseString(json['gender']),
      heightFeet: _parseInt(json['height_feet']),
      heightInches: _parseInt(json['height_inches']),
      heightTotalInches: _parseInt(json['height_total_inches']),
      jerseyNo: _parseString(json['jersey_no']),
      imageUrl: _parseString(json['image_url']),
      profileImageUrl: _parseString(json['profile_image_url']),
      profileUrl: _parseString(json['profile_url']),
      parentVerified: _parseString(json['parent_verified']),
      parentRegistered: _parseString(json['parent_registered']),
      guest: _parseString(json['guest']),
      location: _parseString(json['location']),
      gradYear: _parseString(json['grad_year']),
      primaryPosition: _parseString(json['primary_position']),
      otherPositions: _parseString(json['other_positions']),
    );
  }
}
