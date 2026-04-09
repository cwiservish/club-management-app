import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../enums/member_role.dart';
import '../enums/player_position.dart';

class RosterMember {
  final String id;
  final String firstName;
  final String lastName;
  final MemberRole role;
  final PlayerPosition? position;
  final int? jerseyNumber;
  final String? staffTitle;
  final String phone;
  final String email;
  final String? parentName;
  final String? parentPhone;
  final int attendancePercent;
  final int goalsScored;
  final int assists;
  final int yellowCards;
  final int redCards;
  final bool isActive;
  final Color avatarColor;

  const RosterMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.position,
    this.jerseyNumber,
    this.staffTitle,
    required this.phone,
    required this.email,
    this.parentName,
    this.parentPhone,
    required this.attendancePercent,
    this.goalsScored = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.isActive = true,
    required this.avatarColor,
  });

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}';

  String get positionLabel {
    switch (position) {
      case PlayerPosition.goalkeeper: return 'GK';
      case PlayerPosition.defender: return 'DEF';
      case PlayerPosition.midfielder: return 'MID';
      case PlayerPosition.forward: return 'FWD';
      case null: return '';
    }
  }

  String get positionFull {
    switch (position) {
      case PlayerPosition.goalkeeper: return 'Goalkeeper';
      case PlayerPosition.defender: return 'Defender';
      case PlayerPosition.midfielder: return 'Midfielder';
      case PlayerPosition.forward: return 'Forward';
      case null: return '';
    }
  }

  String get displayRole =>
      role == MemberRole.staff ? (staffTitle ?? 'Staff') : positionFull;

  Color get attendanceColor {
    if (attendancePercent >= 90) return AppColors.success;
    if (attendancePercent >= 75) return AppColors.warning;
    return AppColors.error;
  }
}
