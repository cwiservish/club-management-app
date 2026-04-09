import 'package:flutter/material.dart';

/// Club Management App — TeamDetail + EventDetail + EventForm
/// Converted from Figma Make (Club-Management-App)
/// Three screens in one file, each self-contained and navigable.

// ─── Shared Constants ─────────────────────────────────────────────────────────

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

// ─── Shared Data Models ───────────────────────────────────────────────────────

enum EventType { game, practice, other }

class TeamMember {
  final String name;
  final String role; // e.g. "Forward", "Head Coach"
  final Color avatarColor;
  final String initials;
  final int? jerseyNumber;

  const TeamMember({
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.initials,
    this.jerseyNumber,
  });
}

class TeamSeason {
  final int wins;
  final int losses;
  final int draws;
  final int goalsFor;
  final int goalsAgainst;
  final int rank;
  final String seasonName;

  const TeamSeason({
    required this.wins,
    required this.losses,
    required this.draws,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.rank,
    required this.seasonName,
  });
}

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
}

// ─── Sample Data ──────────────────────────────────────────────────────────────

const _sampleSeason = TeamSeason(
  wins: 8,
  losses: 2,
  draws: 1,
  goalsFor: 27,
  goalsAgainst: 11,
  rank: 3,
  seasonName: 'Spring 2026',
);

final _sampleMembers = [
  const TeamMember(
      name: 'Carlos Martinez',
      role: 'Head Coach',
      avatarColor: _blue,
      initials: 'CM'),
  const TeamMember(
      name: 'Sarah Johnson',
      role: 'Asst. Coach',
      avatarColor: _purple,
      initials: 'SJ'),
  const TeamMember(
      name: 'Oliver Davis',
      role: 'Midfielder',
      avatarColor: Color(0xFF0EA5E9),
      initials: 'OD',
      jerseyNumber: 10),
  const TeamMember(
      name: 'James Miller',
      role: 'Forward',
      avatarColor: Color(0xFFF97316),
      initials: 'JM',
      jerseyNumber: 9),
  const TeamMember(
      name: 'Henry Thomas',
      role: 'Midfielder',
      avatarColor: _purple,
      initials: 'HT',
      jerseyNumber: 6),
  const TeamMember(
      name: 'Noah Williams',
      role: 'Defender',
      avatarColor: _green,
      initials: 'NW',
      jerseyNumber: 4),
  const TeamMember(
      name: 'Liam Anderson',
      role: 'Goalkeeper',
      avatarColor: _amber,
      initials: 'LA',
      jerseyNumber: 1),
  const TeamMember(
      name: 'Lucas Wilson',
      role: 'Forward',
      avatarColor: Color(0xFF14B8A6),
      initials: 'LW',
      jerseyNumber: 11),
];

final _sampleEvent = ClubEvent(
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
  notes:
      'Please arrive 30 minutes early for warm-up. Bring both home and away kits.',
  rsvpYes: ['Oliver D.', 'James M.', 'Henry T.', 'Noah W.', 'Liam A.'],
  rsvpNo: ['Aiden T.'],
  rsvpMaybe: ['Lucas W.', 'Mason J.'],
);

// ─── Shared Helpers ───────────────────────────────────────────────────────────

String _monthName(int m) {
  const n = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return n[m];
}

String _dayName(int weekday) {
  const n = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  return n[weekday];
}

String _formatTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final suffix = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $suffix';
}

Color _eventColor(EventType t) {
  switch (t) {
    case EventType.game:
      return _blue;
    case EventType.practice:
      return _green;
    case EventType.other:
      return _purple;
  }
}

Color _eventBg(EventType t) {
  switch (t) {
    case EventType.game:
      return const Color(0xFFEFF6FF);
    case EventType.practice:
      return const Color(0xFFECFDF5);
    case EventType.other:
      return const Color(0xFFF5F3FF);
  }
}

IconData _eventIcon(EventType t) {
  switch (t) {
    case EventType.game:
      return Icons.sports_soccer;
    case EventType.practice:
      return Icons.fitness_center;
    case EventType.other:
      return Icons.event_note_outlined;
  }
}

String _eventTypeLabel(EventType t) {
  switch (t) {
    case EventType.game:
      return 'Game';
    case EventType.practice:
      return 'Practice';
    case EventType.other:
      return 'Other';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 1. TEAM DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({super.key});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gray50,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _buildSliverHeader(),
          _buildSliverTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildRosterTab(),
            _buildScheduleTab(),
          ],
        ),
      ),
    );
  }

  // ── Sliver Header (gradient banner) ──────────────────────────────────────

  SliverAppBar _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _blue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A56DB), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.sports_soccer,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'U14 Boys Premier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Playbook365 FC • Spring 2026',
                              style: TextStyle(
                                color: Color(0xFFBFDBFE),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Season stats strip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _headerStat('${_sampleSeason.wins}', 'Wins'),
                      _headerDivider(),
                      _headerStat('${_sampleSeason.losses}', 'Losses'),
                      _headerDivider(),
                      _headerStat('${_sampleSeason.draws}', 'Draws'),
                      _headerDivider(),
                      _headerStat(
                          '${_sampleSeason.goalsFor}–${_sampleSeason.goalsAgainst}',
                          'Goals'),
                      _headerDivider(),
                      _headerStat(
                          '#${_sampleSeason.rank}', 'Rank'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerStat(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFBFDBFE), fontSize: 11)),
        ],
      );

  Widget _headerDivider() =>
      Container(width: 1, height: 28, color: Colors.white24);

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  SliverPersistentHeader _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: _blue,
          unselectedLabelColor: _gray400,
          indicatorColor: _blue,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Roster'),
            Tab(text: 'Schedule'),
          ],
        ),
      ),
    );
  }

  // ── Overview Tab ──────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Season Performance card
        _sectionCard(
          title: 'Season Performance',
          child: Column(
            children: [
              _perfRow('Win Rate',
                  '${((_sampleSeason.wins / (_sampleSeason.wins + _sampleSeason.losses + _sampleSeason.draws)) * 100).round()}%',
                  _green),
              const SizedBox(height: 10),
              _perfRow('Goals Scored', '${_sampleSeason.goalsFor}', _blue),
              const SizedBox(height: 10),
              _perfRow(
                  'Goals Conceded', '${_sampleSeason.goalsAgainst}', _red),
              const SizedBox(height: 10),
              _perfRow('Goal Difference',
                  '+${_sampleSeason.goalsFor - _sampleSeason.goalsAgainst}',
                  _green),
              const SizedBox(height: 14),
              // W-D-L progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    Expanded(
                      flex: _sampleSeason.wins,
                      child: Container(height: 10, color: _green),
                    ),
                    Expanded(
                      flex: _sampleSeason.draws,
                      child: Container(height: 10, color: _amber),
                    ),
                    Expanded(
                      flex: _sampleSeason.losses,
                      child: Container(height: 10, color: _red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _legendDot(_green, 'W ${_sampleSeason.wins}'),
                  const SizedBox(width: 12),
                  _legendDot(_amber, 'D ${_sampleSeason.draws}'),
                  const SizedBox(width: 12),
                  _legendDot(_red, 'L ${_sampleSeason.losses}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Next Match card
        _sectionCard(
          title: 'Next Match',
          child: _nextMatchCard(),
        ),
        const SizedBox(height: 16),
        // Quick info
        _sectionCard(
          title: 'Team Info',
          child: Column(
            children: [
              _infoRow(Icons.people_outline, 'Players', '16 active'),
              const Divider(height: 20, color: _gray100),
              _infoRow(Icons.person_outline, 'Staff', '2 members'),
              const Divider(height: 20, color: _gray100),
              _infoRow(Icons.sports_outlined, 'Division', 'Premier League U14'),
              const Divider(height: 20, color: _gray100),
              _infoRow(Icons.location_on_outlined, 'Home Ground',
                  'Centennial Sports Complex'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _perfRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: _gray500)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: _gray500)),
      ],
    );
  }

  Widget _nextMatchCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_soccer, color: _blue, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('vs. Riverside FC',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _gray900)),
                SizedBox(height: 3),
                Text('Sat, Mar 29 • 10:00 AM • Home',
                    style: TextStyle(fontSize: 12, color: _gray500)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EventDetailScreen())),
            child: const Text('Details',
                style: TextStyle(
                    fontSize: 12,
                    color: _blue,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _gray400),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(fontSize: 14, color: _gray500)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _gray700)),
      ],
    );
  }

  // ── Roster Tab ────────────────────────────────────────────────────────────

  Widget _buildRosterTab() {
    final coaches = _sampleMembers
        .where((m) => m.jerseyNumber == null)
        .toList();
    final players = _sampleMembers
        .where((m) => m.jerseyNumber != null)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _rosterSection('Coaching Staff', coaches),
        const SizedBox(height: 16),
        _rosterSection('Players', players),
      ],
    );
  }

  Widget _rosterSection(String title, List<TeamMember> members) {
    return _sectionCard(
      title: title,
      child: Column(
        children: members.asMap().entries.map((entry) {
          final m = entry.value;
          final isLast = entry.key == members.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: m.avatarColor.withOpacity(0.15),
                        child: Text(m.initials,
                            style: TextStyle(
                                color: m.avatarColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (m.jerseyNumber != null)
                        Positioned(
                          bottom: -3,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: _blue,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                            ),
                            child: Text('#${m.jerseyNumber}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _gray900)),
                        Text(m.role,
                            style: const TextStyle(
                                fontSize: 12, color: _gray500)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: _gray400, size: 18),
                ],
              ),
              if (!isLast)
                const Divider(height: 18, color: _gray100),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Schedule Tab ──────────────────────────────────────────────────────────

  Widget _buildScheduleTab() {
    final events = [
      _sampleEvent,
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
        subtitle: 'U14 Boys — Away',
        dateTime: DateTime(2026, 4, 5, 14, 0),
        duration: const Duration(hours: 2),
        location: 'Eagles Stadium, Edmond',
        type: EventType.game,
        isHome: false,
        opponent: 'Eagles SC',
        rsvpRequired: true,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: events.map((e) => _scheduleEventTile(e)).toList(),
    );
  }

  Widget _scheduleEventTile(ClubEvent event) {
    final color = _eventColor(event.type);
    final bg = _eventBg(event.type);
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const EventDetailScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(_eventIcon(event.type), color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _gray900)),
                  const SizedBox(height: 3),
                  Text(
                      '${_dayName(event.dateTime.weekday).substring(0, 3)}, ${_monthName(event.dateTime.month).substring(0, 3)} ${event.dateTime.day} • ${_formatTime(event.dateTime)}',
                      style:
                          const TextStyle(fontSize: 12, color: _gray500)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _gray400, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Shared Section Card ───────────────────────────────────────────────────

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _gray900)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Tab Bar Delegate (for SliverPersistentHeader) ───────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(_, __, ___) => Container(
        color: Colors.white,
        child: tabBar,
      );

  @override
  bool shouldRebuild(_TabBarDelegate old) => tabBar != old.tabBar;
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. EVENT DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class EventDetailScreen extends StatefulWidget {
  final ClubEvent? event;
  const EventDetailScreen({super.key, this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String? _myRsvp; // 'yes' | 'no' | 'maybe'

  ClubEvent get event => widget.event ?? _sampleEvent;

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(event.type);
    final bg = _eventBg(event.type);

    return Scaffold(
      backgroundColor: _gray50,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(color),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventHeader(color, bg),
                  const SizedBox(height: 16),
                  _buildDetailsCard(),
                  const SizedBox(height: 16),
                  if (event.notes != null) ...[
                    _buildNotesCard(),
                    const SizedBox(height: 16),
                  ],
                  if (event.rsvpRequired) ...[
                    _buildRsvpCard(),
                    const SizedBox(height: 16),
                    _buildAttendanceCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(Color color) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: color,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        _eventTypeLabel(event.type),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => EventFormScreen(event: event))),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showMoreMenu(),
        ),
      ],
    );
  }

  Widget _buildEventHeader(Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(_eventIcon(event.type), color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _eventTypeLabel(event.type).toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ),
                    if (event.type == EventType.game) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: event.isHome
                              ? _green.withOpacity(0.1)
                              : _amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.isHome ? 'HOME' : 'AWAY',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: event.isHome ? _green : _amber),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _gray900),
                ),
                Text(event.subtitle,
                    style:
                        const TextStyle(fontSize: 13, color: _gray500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final endTime = event.dateTime.add(event.duration);
    return _detailCard(
      title: 'Event Details',
      children: [
        _detailRow(
            Icons.calendar_today_outlined,
            '${_dayName(event.dateTime.weekday)}, ${_monthName(event.dateTime.month)} ${event.dateTime.day}, ${event.dateTime.year}'),
        _detailRow(Icons.access_time,
            '${_formatTime(event.dateTime)} – ${_formatTime(endTime)} (${event.duration.inMinutes} min)'),
        _detailRow(Icons.location_on_outlined, event.location),
        if (event.opponent != null)
          _detailRow(Icons.sports_soccer,
              'vs. ${event.opponent} (${event.isHome ? "Home" : "Away"})'),
      ],
    );
  }

  Widget _buildNotesCard() {
    return _detailCard(
      title: 'Notes',
      children: [
        Text(event.notes!,
            style: const TextStyle(
                fontSize: 14, color: _gray700, height: 1.5)),
      ],
    );
  }

  Widget _buildRsvpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your RSVP',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _gray900)),
          const SizedBox(height: 14),
          Row(
            children: [
              _rsvpBtn('yes', 'Going', Icons.check_circle_outline, _green),
              const SizedBox(width: 8),
              _rsvpBtn('no', 'Can\'t Go', Icons.cancel_outlined, _red),
              const SizedBox(width: 8),
              _rsvpBtn('maybe', 'Maybe', Icons.help_outline, _amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rsvpBtn(
      String value, String label, IconData icon, Color color) {
    final isSelected = _myRsvp == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _myRsvp = isSelected ? null : value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : _gray100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? color : _gray400, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : _gray500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final yes = event.rsvpYes;
    final no = event.rsvpNo;
    final maybe = event.rsvpMaybe;
    final total = yes.length + no.length + maybe.length;

    return _detailCard(
      title: 'Team Attendance ($total)',
      children: [
        Row(
          children: [
            _attendanceChip(yes.length, 'Going', _green),
            const SizedBox(width: 8),
            _attendanceChip(maybe.length, 'Maybe', _amber),
            const SizedBox(width: 8),
            _attendanceChip(no.length, 'Can\'t Go', _red),
          ],
        ),
        const SizedBox(height: 14),
        // Going list
        if (yes.isNotEmpty) ...[
          _rsvpGroup('Going', yes, _green),
          const SizedBox(height: 10),
        ],
        if (maybe.isNotEmpty) ...[
          _rsvpGroup('Maybe', maybe, _amber),
          const SizedBox(height: 10),
        ],
        if (no.isNotEmpty) _rsvpGroup('Can\'t Go', no, _red),
      ],
    );
  }

  Widget _attendanceChip(int count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: _gray500)),
          ],
        ),
      ),
    );
  }

  Widget _rsvpGroup(String title, List<String> names, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: names
              .map((n) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gray100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(n,
                        style: const TextStyle(
                            fontSize: 12, color: _gray700)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EventFormScreen(event: event))),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit Event'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _gray900)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _gray400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, color: _gray700, height: 1.4)),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _gray100,
                    borderRadius: BorderRadius.circular(2))),
            _menuItem(Icons.content_copy_outlined, 'Duplicate Event', _gray700),
            _menuItem(Icons.notifications_outlined, 'Send Reminder', _gray700),
            _menuItem(Icons.delete_outline, 'Delete Event', _red),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color)),
      onTap: () => Navigator.pop(context),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 3. EVENT FORM SCREEN (Add / Edit)
// ══════════════════════════════════════════════════════════════════════════════

class EventFormScreen extends StatefulWidget {
  final ClubEvent? event; // null = Add mode, non-null = Edit mode

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  bool get isEdit => widget.event != null;

  // Form state
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _opponentController = TextEditingController();

  EventType _eventType = EventType.game;
  bool _isHome = true;
  bool _rsvpRequired = false;
  DateTime _selectedDate = DateTime(2026, 3, 29);
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final e = widget.event!;
      _titleController.text = e.title;
      _locationController.text = e.location;
      _notesController.text = e.notes ?? '';
      _opponentController.text = e.opponent ?? '';
      _eventType = e.type;
      _isHome = e.isHome;
      _rsvpRequired = e.rsvpRequired;
      _selectedDate = e.dateTime;
      _startTime = TimeOfDay(
          hour: e.dateTime.hour, minute: e.dateTime.minute);
      final end = e.dateTime.add(e.duration);
      _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _opponentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _gray700),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          isEdit ? 'Edit Event' : 'New Event',
          style: const TextStyle(
              color: _gray900,
              fontSize: 17,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventTypeSelector(),
            const SizedBox(height: 16),
            _buildFormCard(children: [
              _field('Event Title', _titleController,
                  hint: 'e.g. vs. Riverside FC',
                  icon: Icons.title),
              const Divider(height: 1, color: _gray100),
              _field('Location', _locationController,
                  hint: 'Field, address…',
                  icon: Icons.location_on_outlined),
            ]),
            const SizedBox(height: 16),
            _buildFormCard(children: [
              _datePicker(),
              const Divider(height: 1, color: _gray100),
              _timePicker('Start Time', _startTime,
                  (t) => setState(() => _startTime = t)),
              const Divider(height: 1, color: _gray100),
              _timePicker('End Time', _endTime,
                  (t) => setState(() => _endTime = t)),
            ]),
            if (_eventType == EventType.game) ...[
              const SizedBox(height: 16),
              _buildFormCard(children: [
                _field('Opponent', _opponentController,
                    hint: 'Team name…',
                    icon: Icons.sports_soccer),
                const Divider(height: 1, color: _gray100),
                _homeAwayToggle(),
              ]),
            ],
            const SizedBox(height: 16),
            _buildFormCard(children: [
              _rsvpToggleRow(),
              const Divider(height: 1, color: _gray100),
              _field('Notes', _notesController,
                  hint: 'Add any notes for the team…',
                  icon: Icons.notes_outlined,
                  maxLines: 3),
            ]),
            const SizedBox(height: 24),
            _buildSaveButton(),
            if (isEdit) ...[
              const SizedBox(height: 12),
              _buildDeleteButton(),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Event Type Selector ───────────────────────────────────────────────────

  Widget _buildEventTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Type',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _gray700)),
        const SizedBox(height: 10),
        Row(
          children: EventType.values.map((t) {
            final isActive = _eventType == t;
            final color = _eventColor(t);
            final bg = _eventBg(t);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: t != EventType.other ? 10 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _eventType = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isActive ? bg : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? color : _gray200,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                  color: color.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(_eventIcon(t),
                            color: isActive ? color : _gray400,
                            size: 22),
                        const SizedBox(height: 6),
                        Text(_eventTypeLabel(t),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isActive ? color : _gray500)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Form Card ─────────────────────────────────────────────────────────────

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── Text Field ────────────────────────────────────────────────────────────

  Widget _field(String label, TextEditingController controller,
      {String hint = '', IconData? icon, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 14 : 0),
              child: Icon(icon, size: 18, color: _gray400),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style:
                  const TextStyle(fontSize: 14, color: _gray900),
              decoration: InputDecoration(
                labelText: label,
                labelStyle:
                    const TextStyle(fontSize: 13, color: _gray400),
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 14, color: _gray400),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Picker ───────────────────────────────────────────────────────────

  Widget _datePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2026),
          lastDate: DateTime(2027),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme:
                  const ColorScheme.light(primary: _blue),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: _gray400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date',
                      style: TextStyle(
                          fontSize: 12, color: _gray400)),
                  const SizedBox(height: 2),
                  Text(
                    '${_dayName(_selectedDate.weekday)}, ${_monthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}',
                    style: const TextStyle(
                        fontSize: 14,
                        color: _gray900,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: _gray400),
          ],
        ),
      ),
    );
  }

  // ── Time Picker ───────────────────────────────────────────────────────────

  Widget _timePicker(String label, TimeOfDay time,
      ValueChanged<TimeOfDay> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme:
                  const ColorScheme.light(primary: _blue),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.access_time,
                size: 18, color: _gray400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: _gray400)),
                  const SizedBox(height: 2),
                  Text(
                    time.format(context),
                    style: const TextStyle(
                        fontSize: 14,
                        color: _gray900,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: _gray400),
          ],
        ),
      ),
    );
  }

  // ── Home / Away Toggle ────────────────────────────────────────────────────

  Widget _homeAwayToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              size: 18, color: _gray400),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Venue',
                style: TextStyle(fontSize: 14, color: _gray700)),
          ),
          Container(
            decoration: BoxDecoration(
              color: _gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _venueBtn('Home', true),
                _venueBtn('Away', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _venueBtn(String label, bool isHomeValue) {
    final isActive = _isHome == isHomeValue;
    return GestureDetector(
      onTap: () => setState(() => _isHome = isHomeValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4)
                ]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? _blue : _gray400)),
      ),
    );
  }

  // ── RSVP Toggle ───────────────────────────────────────────────────────────

  Widget _rsvpToggleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.how_to_reg_outlined,
              size: 18, color: _gray400),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RSVP Required',
                    style:
                        TextStyle(fontSize: 14, color: _gray700)),
                Text('Players must respond to this event',
                    style: TextStyle(
                        fontSize: 11, color: _gray400)),
              ],
            ),
          ),
          Switch(
            value: _rsvpRequired,
            onChanged: (v) => setState(() => _rsvpRequired = v),
            activeColor: _blue,
          ),
        ],
      ),
    );
  }

  // ── Save / Delete Buttons ─────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          isEdit ? 'Save Changes' : 'Create Event',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _confirmDelete,
        style: OutlinedButton.styleFrom(
          foregroundColor: _red,
          side: const BorderSide(color: _red),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Delete Event',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _save() {
    Navigator.maybePop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Event',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to delete this event? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _gray500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.maybePop(context);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Entry point (standalone testing — shows TeamDetail) ─────────────────────

void main() {
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Club Management',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _blue),
      fontFamily: 'Inter',
    ),
    home: TeamDetailScreen(),
  ));
}
