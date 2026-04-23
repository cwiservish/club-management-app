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
