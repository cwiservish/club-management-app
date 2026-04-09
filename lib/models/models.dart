import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════════════════

enum EventType { game, practice, other }

enum MemberRole { player, staff }

enum PlayerPosition { goalkeeper, defender, midfielder, forward }

enum ThreadType { team, direct, announcement }

enum MessageType { text, image, file, announcement }

// ═══════════════════════════════════════════════════════════════════════════════
// TEAM & SEASON
// ═══════════════════════════════════════════════════════════════════════════════

class TeamSeason {
  final int wins;
  final int losses;
  final int draws;
  final int goalsFor;
  final int goalsAgainst;
  final int rank;
  final String seasonName;
  final String teamName;
  final String division;

  const TeamSeason({
    required this.wins,
    required this.losses,
    required this.draws,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.rank,
    required this.seasonName,
    required this.teamName,
    required this.division,
  });

  int get totalGames => wins + losses + draws;
  int get goalDifference => goalsFor - goalsAgainst;
  double get winRate => totalGames == 0 ? 0 : wins / totalGames;
  int get points => (wins * 3) + draws;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROSTER MEMBER
// ═══════════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════════
// EVENT
// ═══════════════════════════════════════════════════════════════════════════════

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

  DateTime get endTime => dateTime.add(duration);

  Color get color {
    switch (type) {
      case EventType.game: return AppColors.primary;
      case EventType.practice: return AppColors.success;
      case EventType.other: return AppColors.purple;
    }
  }

  Color get backgroundColor {
    switch (type) {
      case EventType.game: return AppColors.primaryLight;
      case EventType.practice: return AppColors.successLight;
      case EventType.other: return AppColors.purpleLight;
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

// ═══════════════════════════════════════════════════════════════════════════════
// CHAT / MESSAGES
// ═══════════════════════════════════════════════════════════════════════════════

class ChatThread {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final ThreadType type;
  final Color avatarColor;
  final String avatarInitials;
  final bool isOnline;

  const ChatThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    required this.type,
    required this.avatarColor,
    required this.avatarInitials,
    this.isOnline = false,
  });

  bool get hasUnread => unreadCount > 0;
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderInitials;
  final Color senderColor;
  final String? text;
  final MessageType type;
  final DateTime timestamp;
  final bool isMe;
  final String? fileName;
  final String? fileSize;
  final bool isRead;
  final String? reactionEmoji;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderInitials,
    required this.senderColor,
    this.text,
    required this.type,
    required this.timestamp,
    required this.isMe,
    this.fileName,
    this.fileSize,
    this.isRead = false,
    this.reactionEmoji,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// INVOICE
// ═══════════════════════════════════════════════════════════════════════════════

enum InvoiceStatus { paid, pending, overdue }

class Invoice {
  final String id;
  final String invoiceNumber;
  final String description;
  final String playerName;
  final double amount;
  final InvoiceStatus status;
  final DateTime dueDate;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.description,
    required this.playerName,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  Color get statusColor {
    switch (status) {
      case InvoiceStatus.paid: return AppColors.success;
      case InvoiceStatus.pending: return AppColors.warning;
      case InvoiceStatus.overdue: return AppColors.error;
    }
  }

  String get statusLabel {
    switch (status) {
      case InvoiceStatus.paid: return 'Paid';
      case InvoiceStatus.pending: return 'Pending';
      case InvoiceStatus.overdue: return 'Overdue';
    }
  }
}
