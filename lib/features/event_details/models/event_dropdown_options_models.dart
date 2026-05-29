class TimezoneModel {
  final String key;
  final String label;

  TimezoneModel({required this.key, required this.label});

  factory TimezoneModel.fromJson(Map<String, dynamic> json) {
    // Try multiple common field name patterns APIs use
    final key = (json['key'] ??
            json['value'] ??
            json['id'] ??
            json['timezone'] ??
            json['timezone_key'] ??
            '')
        .toString();
    final label = (json['label'] ??
            json['name'] ??
            json['text'] ??
            json['title'] ??
            json['timezone_label'] ??
            json['display_name'] ??
            key)
        .toString();
    return TimezoneModel(key: key, label: label);
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimezoneModel &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          label == other.label;

  @override
  int get hashCode => key.hashCode ^ label.hashCode;
}

class EventDropdownOptionsRequest {
  final String teamUuid;

  EventDropdownOptionsRequest({required this.teamUuid});

  Map<String, dynamic> toJson() => {
    'team_uuid': teamUuid,
  };
}

class EventDropdownOptionsResponse {
  final bool success;
  final String message;
  final List<TimezoneModel> timezones;

  EventDropdownOptionsResponse({
    required this.success,
    required this.message,
    required this.timezones,
  });

  factory EventDropdownOptionsResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true;
    final message = json['message']?.toString() ?? '';

    List<TimezoneModel> timezones = [];

    // Try every plausible response shape
    List<dynamic>? rawList;

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      // Shape 1: data.timezones
      if (data['timezones'] is List) {
        rawList = data['timezones'] as List;
      }
      // Shape 2: data.timezone (singular)
      else if (data['timezone'] is List) {
        rawList = data['timezone'] as List;
      }
      // Shape 3: data.data.timezones (double-nested)
      else if (data['data'] is Map && (data['data'] as Map)['timezones'] is List) {
        rawList = (data['data'] as Map)['timezones'] as List;
      }
      // Shape 4: data itself is a list wrapped in map with numeric/other keys
      else {
        // last resort: look for any List value that looks like timezones
        for (final val in data.values) {
          if (val is List && val.isNotEmpty && val.first is Map) {
            rawList = val;
            break;
          }
        }
      }
    } else if (data is List) {
      // Shape 5: data is directly a list
      rawList = data;
    }

    if (rawList != null) {
      timezones = rawList
          .whereType<Map<String, dynamic>>()
          .map((e) => TimezoneModel.fromJson(e))
          .where((t) => t.key.isNotEmpty)
          .toList();
    }

    return EventDropdownOptionsResponse(
      success: success,
      message: message,
      timezones: timezones,
    );
  }
}
