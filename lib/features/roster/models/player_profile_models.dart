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

class PlayerProfileRequest {
  const PlayerProfileRequest();

  Map<String, dynamic> toJson() => {};
}

class PlayerProfileResponse {
  final bool success;
  final String message;
  final PlayerProfileData data;

  const PlayerProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PlayerProfileResponse.fromJson(Map<String, dynamic> json) {
    return PlayerProfileResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: PlayerProfileData.fromJson(
        json['data'] is Map<String, dynamic> ? json['data'] : {},
      ),
    );
  }
}

class PlayerProfileData {
  final PlayerModel player;
  final List<PlayerParentModel> parents;

  const PlayerProfileData({
    required this.player,
    required this.parents,
  });

  factory PlayerProfileData.fromJson(Map<String, dynamic> json) {
    final list = json['parents'] as List?;
    return PlayerProfileData(
      player: PlayerModel.fromJson(
        json['player'] is Map<String, dynamic> ? json['player'] : {},
      ),
      parents: list
              ?.map((e) => PlayerParentModel.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
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
  final bool isEditable;

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
    required this.isEditable,
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
      isEditable: _parseBool(json['is_editable']),
    );
  }
}

class PlayerParentModel {
  final int id;
  final int customerId;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String mobile;
  final String country;
  final String state;
  final String city;
  final String postalCode;

  const PlayerParentModel({
    required this.id,
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.mobile,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
  });

  factory PlayerParentModel.fromJson(Map<String, dynamic> json) {
    return PlayerParentModel(
      id: _parseInt(json['id']),
      customerId: _parseInt(json['customer_id']),
      firstName: _parseString(json['first_name']),
      lastName: _parseString(json['last_name']),
      name: _parseString(json['name']),
      email: _parseString(json['email']),
      mobile: _parseString(json['mobile']),
      country: _parseString(json['country']),
      state: _parseString(json['state']),
      city: _parseString(json['city']),
      postalCode: _parseString(json['postal_code']),
    );
  }
}
