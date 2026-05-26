import 'player_profile_models.dart';

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

class AssignParentRequest {
  final String teamUuid;
  final String playerUuid;
  final String organizationId;
  final String email;

  const AssignParentRequest({
    required this.teamUuid,
    required this.playerUuid,
    required this.organizationId,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_uuid': teamUuid,
      'player_uuid': playerUuid,
      'organization_id': organizationId,
      'email': email,
    };
  }
}

class AssignParentResponse {
  final bool success;
  final String message;
  final AssignParentData? data;

  const AssignParentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AssignParentResponse.fromJson(Map<String, dynamic> json) {
    return AssignParentResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AssignParentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AssignParentData {
  final List<PlayerParentModel> parents;

  const AssignParentData({
    required this.parents,
  });

  factory AssignParentData.fromJson(Map<String, dynamic> json) {
    final list = json['parents'] as List?;
    return AssignParentData(
      parents: list
              ?.map((e) => PlayerParentModel.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
    );
  }
}
