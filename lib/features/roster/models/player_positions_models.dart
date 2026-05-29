class PlayerPositionModel {
  final int value;
  final int key;
  final String label;

  const PlayerPositionModel({
    required this.value,
    required this.key,
    required this.label,
  });

  factory PlayerPositionModel.fromJson(Map<String, dynamic> json) {
    return PlayerPositionModel(
      value: json['value'] as int? ?? 0,
      key: json['key'] as int? ?? 0,
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'key': key,
      'label': label,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerPositionModel &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}

class PlayerPositionsResponse {
  final bool success;
  final String message;
  final int sportId;
  final List<PlayerPositionModel> positions;

  const PlayerPositionsResponse({
    required this.success,
    required this.message,
    required this.sportId,
    required this.positions,
  });

  factory PlayerPositionsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['positions'] as List?;
    return PlayerPositionsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      sportId: json['sport_id'] as int? ?? 0,
      positions: list
              ?.map((e) => PlayerPositionModel.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
    );
  }
}
