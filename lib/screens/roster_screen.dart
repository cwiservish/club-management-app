import 'package:flutter/material.dart';

/// Club Management App — Roster Screen + Player Detail
/// Converted from Figma Make (Club-Management-App / Roster.tsx + RosterDetail.tsx)
/// Includes: search bar, filter chips (All/Players/Staff), player grid & list toggle,
/// player cards, player detail bottom sheet with stats/attendance/contact.

// ─── Constants ────────────────────────────────────────────────────────────────

const _blue = Color(0xFF1A56DB);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFEF4444);
const _purple = Color(0xFF8B5CF6);
const _gray50 = Color(0xFFF9FAFB);
const _gray100 = Color(0xFFF3F4F6);
const _gray200 = Color(0xFFE5E7EB);
const _gray400 = Color(0xFF9CA3AF);
const _gray500 = Color(0xFF6B7280);
const _gray700 = Color(0xFF374151);
const _gray900 = Color(0xFF111827);

// ─── Data Models ──────────────────────────────────────────────────────────────

enum MemberRole { player, staff }

enum PlayerPosition { goalkeeper, defender, midfielder, forward }

class RosterMember {
  final String id;
  final String firstName;
  final String lastName;
  final MemberRole role;
  final PlayerPosition? position;
  final int? jerseyNumber;
  final String? staffTitle; // e.g. "Head Coach"
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
}

// ─── Sample Data ──────────────────────────────────────────────────────────────

final List<RosterMember> _rosterData = [
  // Staff
  RosterMember(
    id: 's1',
    firstName: 'Carlos',
    lastName: 'Martinez',
    role: MemberRole.staff,
    staffTitle: 'Head Coach',
    phone: '(405) 555-0101',
    email: 'c.martinez@club.com',
    attendancePercent: 100,
    avatarColor: const Color(0xFF1A56DB),
    isActive: true,
  ),
  RosterMember(
    id: 's2',
    firstName: 'Sarah',
    lastName: 'Johnson',
    role: MemberRole.staff,
    staffTitle: 'Assistant Coach',
    phone: '(405) 555-0102',
    email: 's.johnson@club.com',
    attendancePercent: 95,
    avatarColor: const Color(0xFF8B5CF6),
    isActive: true,
  ),
  // Players
  RosterMember(
    id: 'p1',
    firstName: 'Liam',
    lastName: 'Anderson',
    role: MemberRole.player,
    position: PlayerPosition.goalkeeper,
    jerseyNumber: 1,
    phone: '(405) 555-0201',
    email: 'liam.a@email.com',
    parentName: 'Mark Anderson',
    parentPhone: '(405) 555-0211',
    attendancePercent: 92,
    goalsScored: 0,
    assists: 1,
    yellowCards: 0,
    redCards: 0,
    avatarColor: const Color(0xFFF59E0B),
    isActive: true,
  ),
  RosterMember(
    id: 'p2',
    firstName: 'Noah',
    lastName: 'Williams',
    role: MemberRole.player,
    position: PlayerPosition.defender,
    jerseyNumber: 4,
    phone: '(405) 555-0202',
    email: 'noah.w@email.com',
    parentName: 'James Williams',
    parentPhone: '(405) 555-0212',
    attendancePercent: 88,
    goalsScored: 1,
    assists: 3,
    yellowCards: 2,
    redCards: 0,
    avatarColor: const Color(0xFF10B981),
    isActive: true,
  ),
  RosterMember(
    id: 'p3',
    firstName: 'Ethan',
    lastName: 'Brown',
    role: MemberRole.player,
    position: PlayerPosition.defender,
    jerseyNumber: 5,
    phone: '(405) 555-0203',
    email: 'ethan.b@email.com',
    parentName: 'David Brown',
    parentPhone: '(405) 555-0213',
    attendancePercent: 100,
    goalsScored: 2,
    assists: 2,
    yellowCards: 1,
    redCards: 0,
    avatarColor: const Color(0xFFEF4444),
    isActive: true,
  ),
  RosterMember(
    id: 'p4',
    firstName: 'Mason',
    lastName: 'Jones',
    role: MemberRole.player,
    position: PlayerPosition.midfielder,
    jerseyNumber: 8,
    phone: '(405) 555-0204',
    email: 'mason.j@email.com',
    parentName: 'Robert Jones',
    parentPhone: '(405) 555-0214',
    attendancePercent: 75,
    goalsScored: 3,
    assists: 5,
    yellowCards: 1,
    redCards: 0,
    avatarColor: const Color(0xFF6366F1),
    isActive: true,
  ),
  RosterMember(
    id: 'p5',
    firstName: 'Oliver',
    lastName: 'Davis',
    role: MemberRole.player,
    position: PlayerPosition.midfielder,
    jerseyNumber: 10,
    phone: '(405) 555-0205',
    email: 'oliver.d@email.com',
    parentName: 'Michael Davis',
    parentPhone: '(405) 555-0215',
    attendancePercent: 96,
    goalsScored: 5,
    assists: 8,
    yellowCards: 0,
    redCards: 0,
    avatarColor: const Color(0xFF0EA5E9),
    isActive: true,
  ),
  RosterMember(
    id: 'p6',
    firstName: 'James',
    lastName: 'Miller',
    role: MemberRole.player,
    position: PlayerPosition.forward,
    jerseyNumber: 9,
    phone: '(405) 555-0206',
    email: 'james.m@email.com',
    parentName: 'Tom Miller',
    parentPhone: '(405) 555-0216',
    attendancePercent: 83,
    goalsScored: 9,
    assists: 4,
    yellowCards: 3,
    redCards: 1,
    avatarColor: const Color(0xFFF97316),
    isActive: true,
  ),
  RosterMember(
    id: 'p7',
    firstName: 'Lucas',
    lastName: 'Wilson',
    role: MemberRole.player,
    position: PlayerPosition.forward,
    jerseyNumber: 11,
    phone: '(405) 555-0207',
    email: 'lucas.w@email.com',
    parentName: 'Brian Wilson',
    parentPhone: '(405) 555-0217',
    attendancePercent: 91,
    goalsScored: 6,
    assists: 3,
    yellowCards: 1,
    redCards: 0,
    avatarColor: const Color(0xFF14B8A6),
    isActive: true,
  ),
  RosterMember(
    id: 'p8',
    firstName: 'Aiden',
    lastName: 'Taylor',
    role: MemberRole.player,
    position: PlayerPosition.defender,
    jerseyNumber: 3,
    phone: '(405) 555-0208',
    email: 'aiden.t@email.com',
    parentName: 'Chris Taylor',
    parentPhone: '(405) 555-0218',
    attendancePercent: 67,
    goalsScored: 0,
    assists: 1,
    yellowCards: 2,
    redCards: 0,
    avatarColor: const Color(0xFFEC4899),
    isActive: false,
  ),
  RosterMember(
    id: 'p9',
    firstName: 'Henry',
    lastName: 'Thomas',
    role: MemberRole.player,
    position: PlayerPosition.midfielder,
    jerseyNumber: 6,
    phone: '(405) 555-0209',
    email: 'henry.t@email.com',
    parentName: 'Greg Thomas',
    parentPhone: '(405) 555-0219',
    attendancePercent: 100,
    goalsScored: 4,
    assists: 6,
    yellowCards: 0,
    redCards: 0,
    avatarColor: const Color(0xFF8B5CF6),
    isActive: true,
  ),
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _positionLabel(PlayerPosition? p) {
  if (p == null) return '';
  switch (p) {
    case PlayerPosition.goalkeeper:
      return 'GK';
    case PlayerPosition.defender:
      return 'DEF';
    case PlayerPosition.midfielder:
      return 'MID';
    case PlayerPosition.forward:
      return 'FWD';
  }
}

String _positionFull(PlayerPosition? p) {
  if (p == null) return '';
  switch (p) {
    case PlayerPosition.goalkeeper:
      return 'Goalkeeper';
    case PlayerPosition.defender:
      return 'Defender';
    case PlayerPosition.midfielder:
      return 'Midfielder';
    case PlayerPosition.forward:
      return 'Forward';
  }
}

Color _attendanceColor(int pct) {
  if (pct >= 90) return _green;
  if (pct >= 75) return _amber;
  return _red;
}

// ─── Roster Screen ────────────────────────────────────────────────────────────

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  MemberRole? _roleFilter; // null = all
  bool _gridView = true;
  int _navIndex = 2;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RosterMember> get _filtered {
    return _rosterData.where((m) {
      final matchRole = _roleFilter == null || m.role == _roleFilter;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          m.fullName.toLowerCase().contains(q) ||
          (m.staffTitle?.toLowerCase().contains(q) ?? false) ||
          (_positionFull(m.position).toLowerCase().contains(q)) ||
          (m.jerseyNumber?.toString().contains(q) ?? false);
      return matchRole && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final members = _filtered;
    final staff = members.where((m) => m.role == MemberRole.staff).toList();
    final players = members.where((m) => m.role == MemberRole.player).toList();

    return Scaffold(
      backgroundColor: _gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterRow(),
            Expanded(
              child: _buildList(staff, players),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person_add_outlined),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Roster',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _gray900,
            ),
          ),
          const Spacer(),
          // Team badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Text(
              'U14 Boys',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Grid / List toggle
          GestureDetector(
            onTap: () => setState(() => _gridView = !_gridView),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _gridView ? Icons.view_list_outlined : Icons.grid_view,
                size: 20,
                color: _gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search by name, position, #…',
          hintStyle: const TextStyle(color: _gray400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: _gray400, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close, color: _gray400, size: 18),
                )
              : null,
          filled: true,
          fillColor: _gray100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    final chips = [
      (null, 'All (${_rosterData.length})'),
      (MemberRole.player,
          'Players (${_rosterData.where((m) => m.role == MemberRole.player).length})'),
      (MemberRole.staff,
          'Staff (${_rosterData.where((m) => m.role == MemberRole.staff).length})'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: chips.map((chip) {
          final isActive = _roleFilter == chip.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _roleFilter = chip.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? _blue.withOpacity(0.1)
                      : _gray100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _blue : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  chip.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? _blue : _gray500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Main List / Grid ──────────────────────────────────────────────────────

  Widget _buildList(
      List<RosterMember> staff, List<RosterMember> players) {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 48, color: _gray400),
            const SizedBox(height: 12),
            const Text('No members found',
                style: TextStyle(
                    color: _gray500,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search'
                  : 'Tap + to add a member',
              style:
                  const TextStyle(color: _gray400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (staff.isNotEmpty) ...[
          _sectionHeader('Staff', staff.length),
          const SizedBox(height: 8),
          if (_gridView)
            _buildGrid(staff)
          else
            ...staff.map((m) => _buildListTile(m)),
          const SizedBox(height: 16),
        ],
        if (players.isNotEmpty) ...[
          _sectionHeader('Players', players.length),
          const SizedBox(height: 8),
          if (_gridView)
            _buildGrid(players)
          else
            ...players.map((m) => _buildListTile(m)),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _gray700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _gray100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _gray500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: _gray200, thickness: 1)),
      ],
    );
  }

  // ── Grid View ─────────────────────────────────────────────────────────────

  Widget _buildGrid(List<RosterMember> members) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: members.length,
      itemBuilder: (_, i) => _buildGridCard(members[i]),
    );
  }

  Widget _buildGridCard(RosterMember member) {
    return GestureDetector(
      onTap: () => _showDetail(member),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 14),
            // Avatar with jersey number overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: member.avatarColor.withOpacity(0.15),
                  child: Text(
                    member.initials,
                    style: TextStyle(
                      color: member.avatarColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (member.jerseyNumber != null)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '#${member.jerseyNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (!member.isActive)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _gray400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                member.firstName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _gray900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                member.lastName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _gray700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: member.role == MemberRole.staff
                    ? _purple.withOpacity(0.1)
                    : _blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                member.role == MemberRole.staff
                    ? (member.staffTitle ?? 'Staff')
                    : _positionFull(member.position),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: member.role == MemberRole.staff
                      ? _purple
                      : _blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ── List View ─────────────────────────────────────────────────────────────

  Widget _buildListTile(RosterMember member) {
    return GestureDetector(
      onTap: () => _showDetail(member),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: member.avatarColor.withOpacity(0.15),
                  child: Text(
                    member.initials,
                    style: TextStyle(
                      color: member.avatarColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (member.jerseyNumber != null)
                  Positioned(
                    bottom: -3,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '#${member.jerseyNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _gray900,
                        ),
                      ),
                      if (!member.isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _gray100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: 9,
                              color: _gray400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.role == MemberRole.staff
                        ? (member.staffTitle ?? 'Staff')
                        : _positionFull(member.position),
                    style:
                        const TextStyle(fontSize: 12, color: _gray500),
                  ),
                ],
              ),
            ),
            // Attendance pill
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        _attendanceColor(member.attendancePercent)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${member.attendancePercent}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _attendanceColor(member.attendancePercent),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'attendance',
                  style: TextStyle(fontSize: 10, color: _gray400),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _gray400, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Player Detail Sheet ───────────────────────────────────────────────────

  void _showDetail(RosterMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _gray100,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailHeader(member),
                    const SizedBox(height: 20),
                    if (member.role == MemberRole.player) ...[
                      _buildStatRow(member),
                      const SizedBox(height: 20),
                      _buildAttendanceBar(member),
                      const SizedBox(height: 20),
                    ],
                    _buildContactSection(member),
                    if (member.parentName != null) ...[
                      const SizedBox(height: 16),
                      _buildParentSection(member),
                    ],
                    const SizedBox(height: 20),
                    _buildActionButtons(member),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(RosterMember member) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: member.avatarColor.withOpacity(0.15),
              child: Text(
                member.initials,
                style: TextStyle(
                  color: member.avatarColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (member.jerseyNumber != null)
              Positioned(
                bottom: -4,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '#${member.jerseyNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _gray900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: member.role == MemberRole.staff
                          ? _purple.withOpacity(0.1)
                          : _blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      member.role == MemberRole.staff
                          ? (member.staffTitle ?? 'Staff')
                          : _positionFull(member.position),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: member.role == MemberRole.staff
                            ? _purple
                            : _blue,
                      ),
                    ),
                  ),
                  if (member.role == MemberRole.player &&
                      member.position != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _positionLabel(member.position),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _gray500,
                        ),
                      ),
                    ),
                  ],
                  if (!member.isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _gray400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(RosterMember member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCell('${member.goalsScored}', 'Goals', _blue),
          _vertDivider(),
          _statCell('${member.assists}', 'Assists', _green),
          _vertDivider(),
          _statCell('${member.yellowCards}', 'Yellow', _amber),
          _vertDivider(),
          _statCell('${member.redCards}', 'Red', _red),
        ],
      ),
    );
  }

  Widget _statCell(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: _gray500)),
      ],
    );
  }

  Widget _vertDivider() =>
      Container(width: 1, height: 36, color: _gray200);

  Widget _buildAttendanceBar(RosterMember member) {
    final pct = member.attendancePercent / 100;
    final color = _attendanceColor(member.attendancePercent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Attendance',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _gray700)),
            Text(
              '${member.attendancePercent}%',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: _gray100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(RosterMember member) {
    return _infoCard(
      title: 'Contact',
      icon: Icons.person_outline,
      rows: [
        (Icons.phone_outlined, member.phone),
        (Icons.email_outlined, member.email),
      ],
    );
  }

  Widget _buildParentSection(RosterMember member) {
    return _infoCard(
      title: 'Parent / Guardian',
      icon: Icons.family_restroom_outlined,
      rows: [
        (Icons.person_outline, member.parentName!),
        (Icons.phone_outlined, member.parentPhone!),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<(IconData, String)> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _gray400),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _gray500)),
            ],
          ),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(r.$1, size: 15, color: _gray400),
                    const SizedBox(width: 10),
                    Text(r.$2,
                        style: const TextStyle(
                            fontSize: 14, color: _gray700)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(RosterMember member) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.calendar_today_outlined, Icons.calendar_today, 'Schedule'),
      (Icons.people_outline, Icons.people, 'Roster'),
      (Icons.chat_bubble_outline, Icons.chat_bubble, 'Messages'),
      (Icons.more_horiz, Icons.more_horiz, 'More'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == _navIndex;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? item.$2 : item.$1,
                      color: isActive ? _blue : _gray400,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$3,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? _blue : _gray400,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Entry point (standalone testing) ────────────────────────────────────────

void main() {
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Roster',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _blue),
      fontFamily: 'Inter',
    ),
    home: RosterScreen(),
  ));
}
