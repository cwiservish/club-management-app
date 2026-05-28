class Team {
  final int teamId;
  final String uuid;
  final String name;
  final String urlKey;
  final String logo;
  final String gender;
  final String division;
  final String level;
  final String levelTwo;
  final int sportId;
  final int clientId;
  final int organizationId;
  final String organizationUuid;
  final String organizationName;
  final String logoUrl;
  final String url;
  final String domainUrl;
  final List<String> roles;
  final String role;
  final bool isCoach;
  final bool isParent;
  final String code;
  final List<TeamPlayer> players;

  Team({
    required this.teamId,
    required this.uuid,
    required this.name,
    required this.urlKey,
    required this.logo,
    required this.gender,
    required this.division,
    required this.level,
    required this.levelTwo,
    required this.sportId,
    required this.clientId,
    required this.organizationId,
    required this.organizationUuid,
    required this.organizationName,
    required this.logoUrl,
    required this.url,
    required this.domainUrl,
    required this.roles,
    required this.role,
    required this.isCoach,
    required this.isParent,
    required this.code,
    required this.players,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: _parseInt(json['team_id']),
      uuid: _parseString(json['uuid']),
      name: _parseString(json['name']),
      urlKey: _parseString(json['url_key']),
      logo: _parseString(json['logo']),
      gender: _parseString(json['gender']),
      division: _parseString(json['division']),
      level: _parseString(json['level']),
      levelTwo: _parseString(json['level_two']),
      sportId: _parseInt(json['sport_id']),
      clientId: _parseInt(json['client_id']),
      organizationId: _parseInt(json['organization_id']),
      organizationUuid: _parseString(json['organization_uuid']),
      organizationName: _parseString(json['organization_name']),
      logoUrl: _parseString(json['logo_url']),
      url: _parseString(json['url']),
      domainUrl: _parseString(json['domain_url']),
      roles: _parseStringList(json['roles']),
      role: _parseString(json['role']),
      isCoach: _parseBool(json['is_coach']),
      isParent: _parseBool(json['is_parent']),
      code: _parseString(json['code']),
      players: _parsePlayersList(json['players']),
    );
  }

  Map<String, dynamic> toJson() => {
    'team_id': teamId,
    'uuid': uuid,
    'name': name,
    'url_key': urlKey,
    'logo': logo,
    'gender': gender,
    'division': division,
    'level': level,
    'level_two': levelTwo,
    'sport_id': sportId,
    'client_id': clientId,
    'organization_id': organizationId,
    'organization_uuid': organizationUuid,
    'organization_name': organizationName,
    'logo_url': logoUrl,
    'url': url,
    'domain_url': domainUrl,
    'roles': roles,
    'role': role,
    'is_coach': isCoach,
    'is_parent': isParent,
    'code': code,
    'players': players.map((p) => p.toJson()).toList(),
  };

  // ─── Type-Safe Parsing Helpers ────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').toList();
    }
    return [];
  }

  static List<TeamPlayer> _parsePlayersList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => TeamPlayer.fromJson(e is Map<String, dynamic> ? e : {}))
          .toList();
    }
    return [];
  }
}

class TeamPlayer {
  final int playerId;
  final String uuid;
  final String firstName;
  final String lastName;
  final String name;
  final String profileImageUrl;
  final String imageUrl;
  final String profileUrl;

  TeamPlayer({
    required this.playerId,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.profileImageUrl,
    required this.imageUrl,
    required this.profileUrl,
  });

  factory TeamPlayer.fromJson(Map<String, dynamic> json) {
    return TeamPlayer(
      playerId: Team._parseInt(json['player_id']),
      uuid: Team._parseString(json['uuid']),
      firstName: Team._parseString(json['first_name']),
      lastName: Team._parseString(json['last_name']),
      name: Team._parseString(json['name']),
      profileImageUrl: Team._parseString(json['profile_image_url']),
      imageUrl: Team._parseString(json['image_url']),
      profileUrl: Team._parseString(json['profile_url']),
    );
  }

  Map<String, dynamic> toJson() => {
    'player_id': playerId,
    'uuid': uuid,
    'first_name': firstName,
    'last_name': lastName,
    'name': name,
    'profile_image_url': profileImageUrl,
    'image_url': imageUrl,
    'profile_url': profileUrl,
  };
}

