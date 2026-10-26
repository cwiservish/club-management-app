import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../enums/event_type.dart';

class ClubEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime dateTime;
  final Duration duration;
  final String location;
  final EventType type;
  final bool isHome;
  final String? opponent;
  final bool rsvpRequired;
  final String? notes;
  final List<String> rsvpYes;
  final List<String> rsvpNo;
  final List<String> rsvpMaybe;

  // Raw API fields needed for edit pre-fill
  final int schedulingMode;
  final int existingSchedulingMode;
  final int eventTypeKey;
  final int homeAwayKey;
  final int opponentTeamId;
  final String uniformTopColor;
  final String uniformBottomColor;
  final String uniformSocksColor;
  final int uniformTemplateId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isFullSchedule;
  final String titleRaw;

  final bool timeTbd;
  final String? timeLabel;
  final String? startTimeLabel;
  final String? dateLabel;
  final String? eventDuration;
  final String? schedulingModeLabel;
  final String? homeAwayLabel;
  final String? locationDetails;
  final String? uniformColor;
  final String? arrivalTime;
  final String? flagColor;
  final int? dbId;
  final String? timezone;
  final bool notificationEnabled;
  final int arrivalEarly;
  final int? scheduleGameId;
  final String? latitude;
  final String? longitude;
  final bool requiresPlayerSelection;
  final List<ClubEventRsvpTarget> rsvpTargets;
  final int status;
  final String? eventName;
  final int eventFrom;
  final int eventId;
  /// Series code shared by every date of one save; recurringType 2 weekly, 3 specific dates, 1 one date.
  final String code;
  final int recurringType;
  final int? venueId;
  final int? fieldId;
  final int locationType;
  /// Server flag: the signed-in user may set their own RSVP (false for drafts / cancelled).
  final bool canRsvp;
  /// Per-item uniform colours with server colour names (`uniform_details`).
  final List<UniformDetail> uniformDetails;
  /// False when one occurrence of a series is opened with `id` (date can't move).
  final bool canChangeDate;
  /// False when one occurrence of a series is opened with `id` (no repeat options).
  final bool canChangeRecurrence;

  const ClubEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    required this.duration,
    required this.location,
    required this.type,
    this.isHome = false,
    this.opponent,
    this.rsvpRequired = false,
    this.notes,
    this.rsvpYes = const [],
    this.rsvpNo = const [],
    this.rsvpMaybe = const [],
    this.schedulingMode = 1,
    this.existingSchedulingMode = 1,
    this.eventTypeKey = 0,
    this.homeAwayKey = 0,
    this.opponentTeamId = 0,
    this.uniformTopColor = '',
    this.uniformBottomColor = '',
    this.uniformSocksColor = '',
    this.uniformTemplateId = 0,
    this.startDate,
    this.endDate,
    this.isFullSchedule = false,
    this.titleRaw = '',
    this.timeTbd = false,
    this.timeLabel,
    this.startTimeLabel,
    this.dateLabel,
    this.eventDuration,
    this.schedulingModeLabel,
    this.homeAwayLabel,
    this.locationDetails,
    this.uniformColor,
    this.arrivalTime,
    this.flagColor,
    this.dbId,
    this.timezone,
    this.notificationEnabled = true,
    this.arrivalEarly = 0,
    this.scheduleGameId,
    this.latitude,
    this.longitude,
    this.requiresPlayerSelection = false,
    this.rsvpTargets = const [],
    this.status = 1,
    this.eventName,
    this.eventFrom = 0,
    this.eventId = 0,
    this.code = '',
    this.recurringType = 1,
    this.venueId,
    this.fieldId,
    this.locationType = 1,
    this.canRsvp = true,
    this.uniformDetails = const [],
    this.canChangeDate = true,
    this.canChangeRecurrence = true,
  });

  ClubEvent copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? dateTime,
    Duration? duration,
    String? location,
    EventType? type,
    bool? isHome,
    String? opponent,
    bool? rsvpRequired,
    String? notes,
    List<String>? rsvpYes,
    List<String>? rsvpNo,
    List<String>? rsvpMaybe,
    int? schedulingMode,
    int? existingSchedulingMode,
    int? eventTypeKey,
    int? homeAwayKey,
    int? opponentTeamId,
    String? uniformTopColor,
    String? uniformBottomColor,
    String? uniformSocksColor,
    int? uniformTemplateId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isFullSchedule,
    String? titleRaw,
    bool? timeTbd,
    String? timeLabel,
    String? startTimeLabel,
    String? dateLabel,
    String? eventDuration,
    String? schedulingModeLabel,
    String? homeAwayLabel,
    String? locationDetails,
    String? uniformColor,
    String? arrivalTime,
    String? flagColor,
    int? dbId,
    String? timezone,
    bool? notificationEnabled,
    int? arrivalEarly,
    int? scheduleGameId,
    String? latitude,
    String? longitude,
    bool? requiresPlayerSelection,
    List<ClubEventRsvpTarget>? rsvpTargets,
    int? status,
    String? eventName,
    int? eventFrom,
    int? eventId,
    String? code,
    int? recurringType,
    int? venueId,
    int? fieldId,
    int? locationType,
    bool? canRsvp,
    List<UniformDetail>? uniformDetails,
    bool? canChangeDate,
    bool? canChangeRecurrence,
  }) {
    return ClubEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      type: type ?? this.type,
      isHome: isHome ?? this.isHome,
      opponent: opponent ?? this.opponent,
      rsvpRequired: rsvpRequired ?? this.rsvpRequired,
      notes: notes ?? this.notes,
      rsvpYes: rsvpYes ?? this.rsvpYes,
      rsvpNo: rsvpNo ?? this.rsvpNo,
      rsvpMaybe: rsvpMaybe ?? this.rsvpMaybe,
      schedulingMode: schedulingMode ?? this.schedulingMode,
      existingSchedulingMode: existingSchedulingMode ?? this.existingSchedulingMode,
      eventTypeKey: eventTypeKey ?? this.eventTypeKey,
      homeAwayKey: homeAwayKey ?? this.homeAwayKey,
      opponentTeamId: opponentTeamId ?? this.opponentTeamId,
      uniformTopColor: uniformTopColor ?? this.uniformTopColor,
      uniformBottomColor: uniformBottomColor ?? this.uniformBottomColor,
      uniformSocksColor: uniformSocksColor ?? this.uniformSocksColor,
      uniformTemplateId: uniformTemplateId ?? this.uniformTemplateId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isFullSchedule: isFullSchedule ?? this.isFullSchedule,
      titleRaw: titleRaw ?? this.titleRaw,
      timeTbd: timeTbd ?? this.timeTbd,
      timeLabel: timeLabel ?? this.timeLabel,
      startTimeLabel: startTimeLabel ?? this.startTimeLabel,
      dateLabel: dateLabel ?? this.dateLabel,
      eventDuration: eventDuration ?? this.eventDuration,
      schedulingModeLabel: schedulingModeLabel ?? this.schedulingModeLabel,
      homeAwayLabel: homeAwayLabel ?? this.homeAwayLabel,
      locationDetails: locationDetails ?? this.locationDetails,
      uniformColor: uniformColor ?? this.uniformColor,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      flagColor: flagColor ?? this.flagColor,
      dbId: dbId ?? this.dbId,
      timezone: timezone ?? this.timezone,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      arrivalEarly: arrivalEarly ?? this.arrivalEarly,
      scheduleGameId: scheduleGameId ?? this.scheduleGameId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      requiresPlayerSelection: requiresPlayerSelection ?? this.requiresPlayerSelection,
      rsvpTargets: rsvpTargets ?? this.rsvpTargets,
      status: status ?? this.status,
      eventName: eventName ?? this.eventName,
      eventFrom: eventFrom ?? this.eventFrom,
      eventId: eventId ?? this.eventId,
      code: code ?? this.code,
      recurringType: recurringType ?? this.recurringType,
      venueId: venueId ?? this.venueId,
      fieldId: fieldId ?? this.fieldId,
      locationType: locationType ?? this.locationType,
      canRsvp: canRsvp ?? this.canRsvp,
      uniformDetails: uniformDetails ?? this.uniformDetails,
      canChangeDate: canChangeDate ?? this.canChangeDate,
      canChangeRecurrence: canChangeRecurrence ?? this.canChangeRecurrence,
    );
  }

  DateTime get endTime => dateTime.add(duration);

  Color get color {
    switch (type) {
      case EventType.game: return AppColors.current.primary;
      case EventType.practice: return AppColors.current.success;
      case EventType.other: return AppColors.current.purple;
    }
  }

  Color get backgroundColor {
    switch (type) {
      case EventType.game: return AppColors.current.primaryLight;
      case EventType.practice: return AppColors.current.successLight;
      case EventType.other: return AppColors.current.purpleLight;
    }
  }

  IconData get icon {
    switch (type) {
      case EventType.game: return Icons.sports_soccer;
      case EventType.practice: return Icons.fitness_center;
      case EventType.other: return Icons.event_note_outlined;
    }
  }

  String get typeLabel {
    switch (type) {
      case EventType.game: return 'Game';
      case EventType.practice: return 'Practice';
      case EventType.other: return 'Other';
    }
  }
}

class ClubEventRsvpTarget {
  final String attendeeType;
  final int customerId;
  final int? playerId;
  final String name;
  final int? teamEventAttendeeId;
  final dynamic attendance;
  final String notes;

  const ClubEventRsvpTarget({
    required this.attendeeType,
    required this.customerId,
    this.playerId,
    required this.name,
    this.teamEventAttendeeId,
    required this.attendance,
    required this.notes,
  });
}

/// One entry of `uniform_details`. [colorLabel] is empty for non-standard hex values.
class UniformDetail {
  final String key;
  final String label;
  final String color;
  final String colorLabel;

  const UniformDetail({
    required this.key,
    required this.label,
    required this.color,
    this.colorLabel = '',
  });

  static List<UniformDetail> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((m) {
      return UniformDetail(
        key: m['key']?.toString() ?? '',
        label: m['label']?.toString() ?? '',
        color: m['color']?.toString() ?? '',
        colorLabel: m['color_label']?.toString() ?? '',
      );
    }).where((d) => d.color.isNotEmpty).toList();
  }
}
