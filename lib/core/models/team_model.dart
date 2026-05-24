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
}
