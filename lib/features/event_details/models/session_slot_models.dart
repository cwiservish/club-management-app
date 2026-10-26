// Models for the location-type-1 (Our Facilities) conflict board.
// Endpoints: teams/event/session/generate_slots and teams/event/session/field_availability.

bool _asBool(dynamic v) => v == true || v == 1 || v == '1' || v == 'true';
int? _asInt(dynamic v) => v == null || v == '' ? null : int.tryParse(v.toString());
String _asString(dynamic v) => v == null ? '' : v.toString();

/// One date of a session (a row on the board).
class SessionSlot {
  final String date; // yyyy-MM-dd
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final int locationType;
  final int? venueId;
  final int? fieldId;

  /// false for rows that are not at one of our fields, and for locked rows.
  final bool checked;
  final bool isAvailable;
  final bool isBlocking;
  final List<String> warnings;
  final String message;

  /// Series edits: dates edited separately. Shown but never sent back.
  final bool locked;
  final String lockedLabel;
  final bool confirmOnly;

  const SessionSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.locationType = 1,
    this.venueId,
    this.fieldId,
    this.checked = false,
    this.isAvailable = true,
    this.isBlocking = false,
    this.warnings = const [],
    this.message = '',
    this.locked = false,
    this.lockedLabel = '',
    this.confirmOnly = false,
  });

  factory SessionSlot.fromJson(Map<String, dynamic> json, {SessionSlot? fallback}) {
    final warnings = json['warnings'];
    return SessionSlot(
      date: _asString(json['date']).isNotEmpty ? _asString(json['date']) : (fallback?.date ?? ''),
      startTime: _asString(json['start_time']).isNotEmpty
          ? _asString(json['start_time'])
          : (fallback?.startTime ?? ''),
      endTime: _asString(json['end_time']).isNotEmpty
          ? _asString(json['end_time'])
          : (fallback?.endTime ?? ''),
      locationType: _asInt(json['location_type']) ?? fallback?.locationType ?? 1,
      venueId: _asInt(json['venue_id']) ?? fallback?.venueId,
      fieldId: _asInt(json['field_id']) ?? fallback?.fieldId,
      checked: _asBool(json['checked']),
      isAvailable: json.containsKey('is_available') ? _asBool(json['is_available']) : true,
      isBlocking: _asBool(json['is_blocking']),
      warnings: warnings is List ? warnings.map((e) => e.toString()).toList() : const [],
      message: _asString(json['message']),
      locked: _asBool(json['locked']),
      lockedLabel: _asString(json['locked_label']),
      confirmOnly: _asBool(json['confirm_only']),
    );
  }

  SessionSlot copyWith({
    String? startTime,
    String? endTime,
    int? fieldId,
    bool? checked,
    bool? isAvailable,
    bool? isBlocking,
    List<String>? warnings,
    String? message,
  }) {
    return SessionSlot(
      date: date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      locationType: locationType,
      venueId: venueId,
      fieldId: fieldId ?? this.fieldId,
      checked: checked ?? this.checked,
      isAvailable: isAvailable ?? this.isAvailable,
      isBlocking: isBlocking ?? this.isBlocking,
      warnings: warnings ?? this.warnings,
      message: message ?? this.message,
      locked: locked,
      lockedLabel: lockedLabel,
      confirmOnly: confirmOnly,
    );
  }

  /// Row as the save endpoint expects it inside `slots`.
  Map<String, dynamic> toSaveJson() => {
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        if (fieldId != null) 'field_id': fieldId,
      };
}

/// Result of generate_slots: every date the save would write, with availability.
class SlotBoard {
  final List<SessionSlot> slots;
  final bool hasConflicts;
  final int conflictCount;
  final List<int> excludeIds;

  /// Confirm board only: the series' other dates, to be re-sent when saving changed rows.
  final List<SessionSlot> keptSlots;

  const SlotBoard({
    required this.slots,
    this.hasConflicts = false,
    this.conflictCount = 0,
    this.excludeIds = const [],
    this.keptSlots = const [],
  });

  factory SlotBoard.fromJson(Map<String, dynamic> json) {
    List<SessionSlot> parse(dynamic raw) => raw is List
        ? raw.whereType<Map>().map((e) => SessionSlot.fromJson(Map<String, dynamic>.from(e))).toList()
        : <SessionSlot>[];
    final exclude = json['exclude_ids'];
    final slots = parse(json['slots']);
    return SlotBoard(
      slots: slots,
      hasConflicts: json.containsKey('has_conflicts')
          ? _asBool(json['has_conflicts'])
          : slots.any((s) => s.isBlocking),
      conflictCount: _asInt(json['conflict_count']) ?? slots.where((s) => s.isBlocking).length,
      excludeIds: exclude is List ? exclude.map((e) => _asInt(e)).whereType<int>().toList() : const [],
      keptSlots: parse(json['kept_slots']),
    );
  }
}

/// A board / availability call that the server answered with `success: false`.
class SlotApiException implements Exception {
  final String message;
  final List<Map<String, dynamic>> conflicts;
  const SlotApiException(this.message, {this.conflicts = const []});

  @override
  String toString() => message;
}
