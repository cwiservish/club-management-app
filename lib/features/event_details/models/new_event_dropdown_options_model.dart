import 'event_dropdown_options_models.dart';

// ─── Scheduling Type ──────────────────────────────────────────────────────────

class NewEventSchedulingType {
  final int key;
  final String label;

  const NewEventSchedulingType({required this.key, required this.label});

  factory NewEventSchedulingType.fromJson(Map<String, dynamic> json) {
    return NewEventSchedulingType(
      key: (json['key'] as num).toInt(),
      label: json['label']?.toString() ?? '',
    );
  }
}

// ─── Event Type ───────────────────────────────────────────────────────────────

class NewEventType {
  final int key;
  final String value;
  final String label;

  const NewEventType({required this.key, required this.value, required this.label});

  factory NewEventType.fromJson(Map<String, dynamic> json) {
    return NewEventType(
      key: (json['key'] as num).toInt(),
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

// ─── Home / Away Option ───────────────────────────────────────────────────────

class NewEventHomeAwayOption {
  final int key;
  final String value;
  final String label;

  const NewEventHomeAwayOption({required this.key, required this.value, required this.label});

  factory NewEventHomeAwayOption.fromJson(Map<String, dynamic> json) {
    return NewEventHomeAwayOption(
      key: (json['key'] as num).toInt(),
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

// ─── Arrival Time Option ──────────────────────────────────────────────────────

class NewEventArrivalTimeOption {
  final int key;
  final String label;

  const NewEventArrivalTimeOption({required this.key, required this.label});

  factory NewEventArrivalTimeOption.fromJson(Map<String, dynamic> json) {
    return NewEventArrivalTimeOption(
      key: (json['key'] as num).toInt(),
      label: json['label']?.toString() ?? '',
    );
  }
}

// ─── Full Dropdown Options ────────────────────────────────────────────────────

class NewEventDropdownOptions {
  final List<TimezoneModel> timezones;
  final List<NewEventSchedulingType> schedulingTypes;
  final List<NewEventType> eventTypes;
  final List<NewEventHomeAwayOption> homeAwayOptions;
  final List<NewEventArrivalTimeOption> arrivalTimeOptions;
  final List<dynamic> teams;
  final List<dynamic> uniformTemplates;

  const NewEventDropdownOptions({
    required this.timezones,
    required this.schedulingTypes,
    required this.eventTypes,
    required this.homeAwayOptions,
    required this.arrivalTimeOptions,
    required this.teams,
    required this.uniformTemplates,
  });

  factory NewEventDropdownOptions.fromJson(Map<String, dynamic> json) {
    // timezones
    final timezones = (json['timezones'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => TimezoneModel.fromJson(e))
        .where((t) => t.key.isNotEmpty)
        .toList();

    // scheduling_types comes as a Map keyed by string ("1", "2", "3")
    final schedulingTypesRaw = json['scheduling_types'];
    final List<NewEventSchedulingType> schedulingTypes = [];
    if (schedulingTypesRaw is Map) {
      for (final entry in schedulingTypesRaw.values) {
        if (entry is Map<String, dynamic>) {
          schedulingTypes.add(NewEventSchedulingType.fromJson(entry));
        }
      }
      schedulingTypes.sort((a, b) => a.key.compareTo(b.key));
    }

    // event_types
    final eventTypes = (json['event_types'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => NewEventType.fromJson(e))
        .toList();

    // home_away_options
    final homeAwayOptions = (json['home_away_options'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => NewEventHomeAwayOption.fromJson(e))
        .toList();

    // arrival_time_selection — prepend key=0 "No set arrival time"
    const noArrivalTime = NewEventArrivalTimeOption(key: 0, label: 'No set arrival time');
    final arrivalTimeOptions = [
      noArrivalTime,
      ...(json['arrival_time_selection'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => NewEventArrivalTimeOption.fromJson(e)),
    ];

    // teams + uniform_templates (empty for now, stored for future use)
    final teams = json['teams'] as List? ?? [];
    final uniformTemplates = json['uniform_templates'] as List? ?? [];

    return NewEventDropdownOptions(
      timezones: timezones,
      schedulingTypes: schedulingTypes,
      eventTypes: eventTypes,
      homeAwayOptions: homeAwayOptions,
      arrivalTimeOptions: arrivalTimeOptions,
      teams: teams,
      uniformTemplates: uniformTemplates,
    );
  }
}
