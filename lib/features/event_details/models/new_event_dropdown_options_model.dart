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

// ─── Opponent Team ────────────────────────────────────────────────────────────

class OpponentTeam {
  final int id;
  final String name;

  const OpponentTeam({required this.id, required this.name});

  factory OpponentTeam.fromJson(Map<String, dynamic> json) {
    return OpponentTeam(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
    );
  }
}

// ─── Uniform Item ─────────────────────────────────────────────────────────────

/// API `uniform_items` entry. Fixed items always show a color picker; the
/// rest are optional and picked by the user.
class UniformItemDef {
  final String key;
  final String label;
  final bool isFixed;

  const UniformItemDef({required this.key, required this.label, required this.isFixed});

  static const defaults = [
    UniformItemDef(key: 'top', label: 'Top', isFixed: true),
    UniformItemDef(key: 'bottom', label: 'Bottom', isFixed: true),
    UniformItemDef(key: 'socks', label: 'Socks', isFixed: true),
  ];

  factory UniformItemDef.fromJson(dynamic e) {
    if (e is Map) {
      final key = e['key']?.toString() ?? '';
      final label = e['label']?.toString() ?? '';
      return UniformItemDef(
        key: key,
        label: label.isNotEmpty ? label : key,
        isFixed: e['is_fixed'] == true || e['is_fixed'] == 1,
      );
    }
    final key = e.toString();
    return UniformItemDef(key: key, label: key, isFixed: true);
  }
}

// ─── Uniform Template ─────────────────────────────────────────────────────────

class NewEventUniformTemplate {
  final int id;
  final String templateName;
  final String topColor;
  final String bottomColor;
  final String socksColor;

  /// Hex color per uniform item (e.g. "cap" -> "#112233"); only non-empty entries.
  final Map<String, String> colors;

  const NewEventUniformTemplate({
    required this.id,
    required this.templateName,
    required this.topColor,
    required this.bottomColor,
    required this.socksColor,
    this.colors = const {},
  });

  factory NewEventUniformTemplate.fromJson(Map<String, dynamic> json) {
    final colors = <String, String>{};
    for (final entry in json.entries) {
      final k = entry.key;
      if (k.endsWith('_color') && k != 'template_color') {
        final v = entry.value?.toString() ?? '';
        if (v.isNotEmpty) colors[k.substring(0, k.length - 6)] = v;
      }
    }
    final nested = json['uniform'];
    if (nested is Map) {
      for (final entry in nested.entries) {
        final v = entry.value?.toString() ?? '';
        if (v.isNotEmpty) colors[entry.key.toString()] = v;
      }
    }
    return NewEventUniformTemplate(
      colors: colors,
      id: (json['id'] as num).toInt(),
      templateName: json['template_name']?.toString() ?? '',
      topColor: json['top_color']?.toString() ?? '',
      bottomColor: json['bottom_color']?.toString() ?? '',
      socksColor: json['socks_color']?.toString() ?? '',
    );
  }
}

// ─── Location Types ─────────────────────────────────────────────────────────

class NewEventLocationType {
  final int key;
  final int value;
  final String label;

  const NewEventLocationType({
    required this.key,
    required this.value,
    required this.label,
  });

  factory NewEventLocationType.fromJson(Map<String, dynamic> json) {
    return NewEventLocationType(
      key: (json['key'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toInt() ?? 0,
      label: json['label']?.toString() ?? '',
    );
  }
}

// ─── Our Locations (Venues & Fields) ─────────────────────────────────────────

class OurLocationField {
  final int fieldId;
  final int venueId;
  final String parentId;
  final String fieldName;
  final String label;

  const OurLocationField({
    required this.fieldId,
    required this.venueId,
    required this.parentId,
    required this.fieldName,
    required this.label,
  });

  /// Static last option of the Field dropdown: the field is decided later (`field_id` 0).
  static const OurLocationField tbd = OurLocationField(
    fieldId: 0,
    venueId: 0,
    parentId: '',
    fieldName: 'TBD',
    label: 'TBD',
  );

  bool get isTbd => fieldId == 0;

  factory OurLocationField.fromJson(Map<String, dynamic> json) {
    return OurLocationField(
      fieldId: (json['field_id'] as num?)?.toInt() ?? 0,
      venueId: (json['venue_id'] as num?)?.toInt() ?? 0,
      parentId: json['parent_id']?.toString() ?? '',
      fieldName: json['field_name']?.toString() ?? '',
      label: json['label']?.toString() ?? json['field_name']?.toString() ?? '',
    );
  }
}

class OurLocationVenue {
  final int venueId;
  final String name;
  final String label;
  final String latitude;
  final String longitude;
  final List<OurLocationField> fields;

  const OurLocationVenue({
    required this.venueId,
    required this.name,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.fields,
  });

  factory OurLocationVenue.fromJson(Map<String, dynamic> json) {
    final fieldsRaw = json['fields'] as List? ?? [];
    final fields = fieldsRaw
        .whereType<Map<String, dynamic>>()
        .map((e) => OurLocationField.fromJson(e))
        .toList();

    return OurLocationVenue(
      venueId: (json['venue_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      fields: fields,
    );
  }
}

// ─── Saved Locations ─────────────────────────────────────────────────────────

class SavedLocationItem {
  final int id;
  final int savedLocationId;
  final String uuid;
  final int organizationId;
  final String location;
  final String address;
  final String latitude;
  final String longitude;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String placeId;
  final String name;
  final String organizationName;

  const SavedLocationItem({
    required this.id,
    required this.savedLocationId,
    required this.uuid,
    required this.organizationId,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.placeId,
    required this.name,
    required this.organizationName,
  });

  factory SavedLocationItem.fromJson(Map<String, dynamic> json) {
    final idVal = (json['id'] as num?)?.toInt() ?? 0;
    return SavedLocationItem(
      id: idVal,
      savedLocationId: (json['saved_location_id'] as num?)?.toInt() ?? idVal,
      uuid: json['uuid']?.toString() ?? '',
      organizationId: (json['organization_id'] as num?)?.toInt() ?? 0,
      location: json['location']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      placeId: json['place_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['location']?.toString() ?? '',
      organizationName: json['organization_name']?.toString() ?? '',
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
  final List<OpponentTeam> teams;
  final List<NewEventUniformTemplate> uniformTemplates;
  /// API `uniform_colors`: palette for the uniform color pickers.
  final List<({String label, String hex})> uniformColors;
  final List<UniformItemDef>? _uniformItems;
  // Null-safe for hot reload (objects created before this field existed).
  List<UniformItemDef> get uniformItems => _uniformItems ?? UniformItemDef.defaults;
  final List<NewEventLocationType> locationTypes;
  final List<OurLocationVenue> ourLocations;
  final List<SavedLocationItem> savedLocations;

  const NewEventDropdownOptions({
    required this.timezones,
    required this.schedulingTypes,
    required this.eventTypes,
    required this.homeAwayOptions,
    required this.arrivalTimeOptions,
    required this.teams,
    required this.uniformTemplates,
    List<UniformItemDef> uniformItems = UniformItemDef.defaults,
    this.uniformColors = const [],
    this.locationTypes = const [],
    this.ourLocations = const [],
    this.savedLocations = const [],
  }) : _uniformItems = uniformItems;

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

    // home_away_options — backend may return "" instead of [] when empty
    final homeAwayOptions = (json['home_away_options'] is List ? json['home_away_options'] as List : [])
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

    // teams (opponent teams for game/scrimmage dropdown)
    final teams = (json['teams'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => OpponentTeam.fromJson(e))
        .toList();

    // uniform_templates
    final uniformTemplates = (json['uniform_templates'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => NewEventUniformTemplate.fromJson(e))
        .toList();

    // uniform_items — dynamic list of garments/gear that can have a color
    final uniformItems = (json['uniform_items'] as List? ?? [])
        .map(UniformItemDef.fromJson)
        .where((e) => e.key.isNotEmpty)
        .toList();

    // uniform_colors — [{key, label, value: "#hex"}]
    final uniformColors = (json['uniform_colors'] as List? ?? [])
        .whereType<Map>()
        .map((e) => (label: e['label']?.toString() ?? '', hex: e['value']?.toString() ?? ''))
        .where((c) => c.hex.isNotEmpty)
        .toList();

    // location_types
    final locationTypes = (json['location_types'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => NewEventLocationType.fromJson(e))
        .toList();

    // venues (facilities with their fields); falls back to legacy our_locations
    final venuesRaw = json['venues'] is List && (json['venues'] as List).isNotEmpty
        ? json['venues'] as List
        : (json['our_locations'] as List? ?? []);
    final ourLocations = venuesRaw
        .whereType<Map<String, dynamic>>()
        .map((e) => OurLocationVenue.fromJson(e))
        .toList();

    // saved_locations
    final savedLocations = (json['saved_locations'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => SavedLocationItem.fromJson(e))
        .toList();

    return NewEventDropdownOptions(
      timezones: timezones,
      schedulingTypes: schedulingTypes,
      eventTypes: eventTypes,
      homeAwayOptions: homeAwayOptions,
      arrivalTimeOptions: arrivalTimeOptions,
      teams: teams,
      uniformTemplates: uniformTemplates,
      uniformItems: uniformItems.isNotEmpty ? uniformItems : UniformItemDef.defaults,
      uniformColors: uniformColors,
      locationTypes: locationTypes,
      ourLocations: ourLocations,
      savedLocations: savedLocations,
    );
  }
}
