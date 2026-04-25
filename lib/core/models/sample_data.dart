import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'team_season.dart';
import '../../features/roster/models/roster_member.dart';
import 'club_event.dart';
import 'chat_models.dart';
import 'invoice.dart';
import '../enums/member_role.dart';
import '../enums/player_position.dart';
import '../enums/event_type.dart';
import '../enums/thread_type.dart';
import '../enums/message_type.dart';
import '../enums/invoice_status.dart';

/// Playbook365 — Sample / Mock Data
/// Replace with real API calls in production.

// ─── Team ─────────────────────────────────────────────────────────────────────

final sampleSeason = const TeamSeason(
  wins: 8,
  losses: 2,
  draws: 1,
  goalsFor: 27,
  goalsAgainst: 11,
  rank: 3,
  seasonName: 'Spring 2026',
  teamName: 'U14 Boys Premier',
  division: 'Premier League U14',
);

// ─── Roster ───────────────────────────────────────────────────────────────────

final List<RosterMember> sampleRoster = [
  RosterMember(
    id: 's1',
    firstName: 'Carlos', lastName: 'Martinez',
    role: MemberRole.staff, staffTitle: 'Head Coach',
    phone: '(405) 555-0101', email: 'c.martinez@club.com',
    attendancePercent: 100, avatarColor: AppColors.current.primary,
  ),
  RosterMember(
    id: 's2',
    firstName: 'Sarah', lastName: 'Johnson',
    role: MemberRole.staff, staffTitle: 'Assistant Coach',
    phone: '(405) 555-0102', email: 's.johnson@club.com',
    attendancePercent: 95, avatarColor: AppColors.current.purple,
  ),
  RosterMember(
    id: 'p1',
    firstName: 'Liam', lastName: 'Anderson',
    role: MemberRole.player, position: PlayerPosition.goalkeeper,
    jerseyNumber: 1,
    phone: '(405) 555-0201', email: 'liam.a@email.com',
    parentName: 'Mark Anderson', parentPhone: '(405) 555-0211',
    attendancePercent: 92, goalsScored: 0, assists: 1,
    avatarColor: AppColors.current.warning,
  ),
  RosterMember(
    id: 'p2',
    firstName: 'Noah', lastName: 'Williams',
    role: MemberRole.player, position: PlayerPosition.defender,
    jerseyNumber: 4,
    phone: '(405) 555-0202', email: 'noah.w@email.com',
    parentName: 'James Williams', parentPhone: '(405) 555-0212',
    attendancePercent: 88, goalsScored: 1, assists: 3, yellowCards: 2,
    avatarColor: AppColors.current.success,
  ),
  RosterMember(
    id: 'p3',
    firstName: 'Ethan', lastName: 'Brown',
    role: MemberRole.player, position: PlayerPosition.defender,
    jerseyNumber: 5,
    phone: '(405) 555-0203', email: 'ethan.b@email.com',
    parentName: 'David Brown', parentPhone: '(405) 555-0213',
    attendancePercent: 100, goalsScored: 2, assists: 2, yellowCards: 1,
    avatarColor: AppColors.current.error,
  ),
  RosterMember(
    id: 'p4',
    firstName: 'Mason', lastName: 'Jones',
    role: MemberRole.player, position: PlayerPosition.midfielder,
    jerseyNumber: 8,
    phone: '(405) 555-0204', email: 'mason.j@email.com',
    parentName: 'Robert Jones', parentPhone: '(405) 555-0214',
    attendancePercent: 75, goalsScored: 3, assists: 5, yellowCards: 1,
    avatarColor: AppColors.current.indigo,
  ),
  RosterMember(
    id: 'p5',
    firstName: 'Oliver', lastName: 'Davis',
    role: MemberRole.player, position: PlayerPosition.midfielder,
    jerseyNumber: 10,
    phone: '(405) 555-0205', email: 'oliver.d@email.com',
    parentName: 'Michael Davis', parentPhone: '(405) 555-0215',
    attendancePercent: 96, goalsScored: 5, assists: 8,
    avatarColor: AppColors.current.sky,
  ),
  RosterMember(
    id: 'p6',
    firstName: 'James', lastName: 'Miller',
    role: MemberRole.player, position: PlayerPosition.forward,
    jerseyNumber: 9,
    phone: '(405) 555-0206', email: 'james.m@email.com',
    parentName: 'Tom Miller', parentPhone: '(405) 555-0216',
    attendancePercent: 83, goalsScored: 9, assists: 4,
    yellowCards: 3, redCards: 1,
    avatarColor: AppColors.current.orange,
  ),
  RosterMember(
    id: 'p7',
    firstName: 'Lucas', lastName: 'Wilson',
    role: MemberRole.player, position: PlayerPosition.forward,
    jerseyNumber: 11,
    phone: '(405) 555-0207', email: 'lucas.w@email.com',
    parentName: 'Brian Wilson', parentPhone: '(405) 555-0217',
    attendancePercent: 91, goalsScored: 6, assists: 3, yellowCards: 1,
    avatarColor: AppColors.current.teal,
  ),
  RosterMember(
    id: 'p8',
    firstName: 'Aiden', lastName: 'Taylor',
    role: MemberRole.player, position: PlayerPosition.defender,
    jerseyNumber: 3,
    phone: '(405) 555-0208', email: 'aiden.t@email.com',
    parentName: 'Chris Taylor', parentPhone: '(405) 555-0218',
    attendancePercent: 67, isActive: false,
    avatarColor: AppColors.current.pink,
  ),
  RosterMember(
    id: 'p9',
    firstName: 'Henry', lastName: 'Thomas',
    role: MemberRole.player, position: PlayerPosition.midfielder,
    jerseyNumber: 6,
    phone: '(405) 555-0209', email: 'henry.t@email.com',
    parentName: 'Greg Thomas', parentPhone: '(405) 555-0219',
    attendancePercent: 100, goalsScored: 4, assists: 6,
    avatarColor: AppColors.current.purple,
  ),
];

// ─── Events ───────────────────────────────────────────────────────────────────

final List<ClubEvent> sampleEvents = [
  ClubEvent(
    id: 'e1',
    title: 'vs. Riverside FC',
    subtitle: 'U14 Boys — Home Game',
    dateTime: DateTime(2026, 3, 29, 10, 0),
    duration: const Duration(hours: 2),
    location: 'Home Field — Centennial Sports Complex',
    type: EventType.game,
    isHome: true,
    opponent: 'Riverside FC',
    rsvpRequired: true,
    notes: 'Please arrive 30 minutes early for warm-up. Bring both home and away kits.',
    rsvpYes: ['Oliver D.', 'James M.', 'Henry T.', 'Noah W.', 'Liam A.'],
    rsvpNo: ['Aiden T.'],
    rsvpMaybe: ['Lucas W.', 'Mason J.'],
  ),
  ClubEvent(
    id: 'e2',
    title: 'Team Practice',
    subtitle: 'U14 Boys',
    dateTime: DateTime(2026, 4, 1, 17, 30),
    duration: const Duration(hours: 1, minutes: 30),
    location: 'Field 3 — Riverside Park',
    type: EventType.practice,
  ),
  ClubEvent(
    id: 'e3',
    title: 'vs. Eagles SC',
    subtitle: 'U14 Boys — Away Game',
    dateTime: DateTime(2026, 4, 5, 14, 0),
    duration: const Duration(hours: 2),
    location: 'Eagles Stadium, Edmond',
    type: EventType.game,
    isHome: false,
    opponent: 'Eagles SC',
    rsvpRequired: true,
  ),
  ClubEvent(
    id: 'e4',
    title: 'Team Practice',
    subtitle: 'U14 Boys',
    dateTime: DateTime(2026, 4, 8, 17, 30),
    duration: const Duration(hours: 1, minutes: 30),
    location: 'Field 3 — Riverside Park',
    type: EventType.practice,
  ),
  ClubEvent(
    id: 'e5',
    title: 'Spring Tournament',
    subtitle: 'All age groups',
    dateTime: DateTime(2026, 4, 12, 9, 0),
    duration: const Duration(hours: 8),
    location: 'Sports Complex, OKC',
    type: EventType.other,
    rsvpRequired: true,
  ),
  ClubEvent(
    id: 'e6',
    title: 'vs. Thunder FC',
    subtitle: 'U14 Boys — Home Game',
    dateTime: DateTime(2026, 4, 19, 11, 0),
    duration: const Duration(hours: 2),
    location: 'Home Field — Centennial',
    type: EventType.game,
    isHome: true,
    opponent: 'Thunder FC',
  ),
];

// ─── Messages ─────────────────────────────────────────────────────────────────

DateTime _ago({int hours = 0, int minutes = 0}) =>
    DateTime.now().subtract(Duration(hours: hours, minutes: minutes));

final List<ChatThread> sampleThreads = [
  ChatThread(
    id: 't1', name: 'U14 Boys — Team Chat',
    lastMessage: 'Coach: Remember warm-up at 9:30 tomorrow!',
    lastMessageTime: _ago(minutes: 10),
    unreadCount: 3, isPinned: true,
    type: ThreadType.team,
    avatarColor: AppColors.current.primary, avatarInitials: 'U14',
  ),
  ChatThread(
    id: 't2', name: 'Club Announcements',
    lastMessage: 'Spring tournament registration closes Friday.',
    lastMessageTime: _ago(hours: 1),
    unreadCount: 1, isPinned: true,
    type: ThreadType.announcement,
    avatarColor: AppColors.current.warning, avatarInitials: '📢',
  ),
  ChatThread(
    id: 't3', name: 'Carlos Martinez',
    lastMessage: 'See you at practice 👍',
    lastMessageTime: _ago(hours: 2, minutes: 30),
    type: ThreadType.direct,
    avatarColor: AppColors.current.primary, avatarInitials: 'CM',
    isOnline: true,
  ),
  ChatThread(
    id: 't4', name: 'Sarah Johnson',
    lastMessage: 'Can you send the lineup for Saturday?',
    lastMessageTime: _ago(hours: 5),
    unreadCount: 2,
    type: ThreadType.direct,
    avatarColor: AppColors.current.purple, avatarInitials: 'SJ',
  ),
  ChatThread(
    id: 't5', name: 'Coaching Staff',
    lastMessage: 'Confirmed: Field 3 is booked.',
    lastMessageTime: _ago(hours: 24),
    type: ThreadType.team,
    avatarColor: AppColors.current.success, avatarInitials: 'CS',
  ),
  ChatThread(
    id: 't6', name: 'Oliver Davis',
    lastMessage: 'I\'ll be there!',
    lastMessageTime: _ago(hours: 26),
    type: ThreadType.direct,
    avatarColor: AppColors.current.sky, avatarInitials: 'OD',
    isOnline: true,
  ),
];

final List<ChatMessage> sampleMessages = [
  ChatMessage(
    id: 'm1', senderId: 'coach',
    senderName: 'Carlos Martinez', senderInitials: 'CM',
    senderColor: AppColors.current.primary,
    text: 'Hey team! Quick reminder about tomorrow\'s game vs Riverside FC.',
    type: MessageType.text,
    timestamp: _ago(hours: 2, minutes: 40),
    isMe: false,
  ),
  ChatMessage(
    id: 'm2', senderId: 'coach',
    senderName: 'Carlos Martinez', senderInitials: 'CM',
    senderColor: AppColors.current.primary,
    text: 'Please arrive at the field by 9:30 AM for warm-up. Game kicks off at 10:00.',
    type: MessageType.text,
    timestamp: _ago(hours: 2, minutes: 39),
    isMe: false,
  ),
  ChatMessage(
    id: 'm3', senderId: 'me',
    senderName: 'You', senderInitials: 'JD',
    senderColor: AppColors.current.sky,
    text: 'Got it coach! Will be there early 💪',
    type: MessageType.text,
    timestamp: _ago(hours: 2, minutes: 35),
    isMe: true, isRead: true,
  ),
  ChatMessage(
    id: 'm4', senderId: 'sarah',
    senderName: 'Sarah Johnson', senderInitials: 'SJ',
    senderColor: AppColors.current.purple,
    text: 'I\'ve attached the match day lineup.',
    type: MessageType.text,
    timestamp: _ago(hours: 2, minutes: 20),
    isMe: false,
  ),
  ChatMessage(
    id: 'm5', senderId: 'sarah',
    senderName: 'Sarah Johnson', senderInitials: 'SJ',
    senderColor: AppColors.current.purple,
    fileName: 'Lineup_Mar29.pdf', fileSize: '245 KB',
    type: MessageType.file,
    timestamp: _ago(hours: 2, minutes: 19),
    isMe: false,
  ),
  ChatMessage(
    id: 'm6', senderId: 'me',
    senderName: 'You', senderInitials: 'JD',
    senderColor: AppColors.current.sky,
    text: 'Thanks! Looking good 👌',
    type: MessageType.text,
    timestamp: _ago(hours: 2, minutes: 10),
    isMe: true, isRead: true, reactionEmoji: '👍',
  ),
  ChatMessage(
    id: 'm7', senderId: 'coach',
    senderName: 'Carlos Martinez', senderInitials: 'CM',
    senderColor: AppColors.current.primary,
    text: 'Remember warm-up at 9:30 tomorrow!',
    type: MessageType.text,
    timestamp: _ago(minutes: 10),
    isMe: false,
  ),
];

// ─── Invoices ─────────────────────────────────────────────────────────────────

final List<Invoice> sampleInvoices = [
  Invoice(
    id: 'i1', invoiceNumber: 'INV-001',
    description: 'Spring Registration', playerName: 'Oliver Davis',
    amount: 150.00, status: InvoiceStatus.paid,
    dueDate: DateTime(2026, 3, 1),
  ),
  Invoice(
    id: 'i2', invoiceNumber: 'INV-002',
    description: 'Spring Registration', playerName: 'James Miller',
    amount: 150.00, status: InvoiceStatus.paid,
    dueDate: DateTime(2026, 3, 1),
  ),
  Invoice(
    id: 'i3', invoiceNumber: 'INV-003',
    description: 'Kit Fee', playerName: 'Noah Williams',
    amount: 65.00, status: InvoiceStatus.pending,
    dueDate: DateTime(2026, 4, 1),
  ),
  Invoice(
    id: 'i4', invoiceNumber: 'INV-004',
    description: 'Tournament Fee', playerName: 'Henry Thomas',
    amount: 45.00, status: InvoiceStatus.overdue,
    dueDate: DateTime(2026, 3, 15),
  ),
  Invoice(
    id: 'i5', invoiceNumber: 'INV-005',
    description: 'Spring Registration', playerName: 'Lucas Wilson',
    amount: 150.00, status: InvoiceStatus.paid,
    dueDate: DateTime(2026, 3, 1),
  ),
  Invoice(
    id: 'i6', invoiceNumber: 'INV-006',
    description: 'Kit Fee', playerName: 'Aiden Taylor',
    amount: 65.00, status: InvoiceStatus.pending,
    dueDate: DateTime(2026, 4, 1),
  ),
];
