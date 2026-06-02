import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/enums/member_role.dart';
import '../../../core/enums/player_position.dart';

class RosterMember {
  final String id;
  final int? playerId;
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
  final String primaryPosition;
  final String gender;
  final String jerseyNo;

  const RosterMember({
    required this.id,
    this.playerId,
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
    this.primaryPosition = '',
    this.gender = '',
    this.jerseyNo = '',
  });

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final combined = '$f$l';
    return combined.isNotEmpty ? combined : '?';
  }

  String get positionLabel {
    switch (position) {
      case PlayerPosition.goalkeeper: return 'GK';
      case PlayerPosition.defender:   return 'DEF';
      case PlayerPosition.midfielder: return 'MID';
      case PlayerPosition.forward:    return 'FWD';
      case null:                      return '';
    }
  }

  String get positionFull {
    switch (position) {
      case PlayerPosition.goalkeeper: return 'Goalkeeper';
      case PlayerPosition.defender:   return 'Defender';
      case PlayerPosition.midfielder: return 'Midfielder';
      case PlayerPosition.forward:    return 'Forward';
      case null:                      return '';
    }
  }

  String get displayPosition {
    final p = primaryPosition.toLowerCase().trim();
    if (p.isEmpty) return positionFull;
    if (p == '1' || p == 'goalkeeper' || p == 'gk') return 'Goalkeeper';
    if (p == '2' || p == 'defender' || p == 'def') return 'Defender';
    if (p == '3' || p == 'midfielder' || p == 'mid') return 'Midfielder';
    if (p == '4' || p == 'forward' || p == 'fwd') return 'Forward';
    return p[0].toUpperCase() + p.substring(1);
  }

  String get displayRole =>
      role == MemberRole.staff ? (staffTitle ?? 'Staff') : displayPosition;

  Color get attendanceColor {
    if (attendancePercent >= 90) return AppColors.current.success;
    if (attendancePercent >= 75) return AppColors.current.warning;
    return AppColors.current.error;
  }
}
