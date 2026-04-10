import 'package:flutter/material.dart';

import '../../../core/models/club_event.dart';
import '../../../core/models/sample_data.dart';
import '../../../core/models/team_season.dart';
import '../../../core/enums/event_type.dart';
import '../../schedule/pages/event_detail_page.dart';

// ─── Local colour palette ─────────────────────────────────────────────────────

const _blue = Color(0xFF1A56DB);
const _gray50 = Color(0xFFF9FAFB);
const _gray100 = Color(0xFFF3F4F6);
const _gray400 = Color(0xFF9CA3AF);
const _gray500 = Color(0xFF6B7280);
const _gray700 = Color(0xFF374151);
const _gray900 = Color(0xFF111827);

// ─── Local data model (no core equivalent) ───────────────────────────────────

class _TeamMember {
  final String name;
  final String role;
  final Color avatarColor;
  final String initials;
  final int? jerseyNumber;

  const _TeamMember({
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.initials,
    this.jerseyNumber,
  });
}

final _sampleMembers = [
  const _TeamMember(
      name: 'Carlos Martinez', role: 'Head Coach',
      avatarColor: _blue, initials: 'CM'),
  const _TeamMember(
      name: 'Sarah Johnson', role: 'Asst. Coach',
      avatarColor: Color(0xFF8B5CF6), initials: 'SJ'),
  const _TeamMember(
      name: 'Oliver Davis', role: 'Midfielder',
      avatarColor: Color(0xFF0EA5E9), initials: 'OD', jerseyNumber: 10),
  const _TeamMember(
      name: 'James Miller', role: 'Forward',
      avatarColor: Color(0xFFF97316), initials: 'JM', jerseyNumber: 9),
  const _TeamMember(
      name: 'Henry Thomas', role: 'Midfielder',
      avatarColor: Color(0xFF8B5CF6), initials: 'HT', jerseyNumber: 6),
  const _TeamMember(
      name: 'Noah Williams', role: 'Defender',
      avatarColor: Color(0xFF10B981), initials: 'NW', jerseyNumber: 4),
  const _TeamMember(
      name: 'Liam Anderson', role: 'Goalkeeper',
      avatarColor: Color(0xFFF59E0B), initials: 'LA', jerseyNumber: 1),
  const _TeamMember(
      name: 'Lucas Wilson', role: 'Forward',
      avatarColor: Color(0xFF14B8A6), initials: 'LW', jerseyNumber: 11),
];

// ─── Date/time helpers ────────────────────────────────────────────────────────

String _monthAbbr(int m) =>
    const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];

String _dayAbbr(int weekday) =>
    const ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday];

String _formatTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
}

// ══════════════════════════════════════════════════════════════════════════════
// TEAM DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({super.key});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  TeamSeason get season => sampleSeason;
  List<ClubEvent> get events => sampleEvents.take(3).toList();

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

  // ── Sliver Header ─────────────────────────────────────────────────────────

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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              season.teamName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Playbook365 FC • ${season.seasonName}',
                              style: const TextStyle(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _headerStat('${season.wins}', 'Wins'),
                      _headerDivider(),
                      _headerStat('${season.losses}', 'Losses'),
                      _headerDivider(),
                      _headerStat('${season.draws}', 'Draws'),
                      _headerDivider(),
                      _headerStat(
                          '${season.goalsFor}–${season.goalsAgainst}', 'Goals'),
                      _headerDivider(),
                      _headerStat('#${season.rank}', 'Rank'),
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
              style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 11)),
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
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
        _sectionCard(
          title: 'Season Performance',
          child: Column(
            children: [
              _perfRow('Win Rate',
                  '${(season.winRate * 100).round()}%',
                  const Color(0xFF10B981)),
              const SizedBox(height: 10),
              _perfRow('Goals Scored', '${season.goalsFor}', _blue),
              const SizedBox(height: 10),
              _perfRow('Goals Conceded', '${season.goalsAgainst}',
                  const Color(0xFFEF4444)),
              const SizedBox(height: 10),
              _perfRow('+${season.goalDifference}', 'Goal Difference',
                  const Color(0xFF10B981)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    Expanded(
                      flex: season.wins,
                      child: Container(
                          height: 10, color: const Color(0xFF10B981)),
                    ),
                    Expanded(
                      flex: season.draws,
                      child: Container(
                          height: 10, color: const Color(0xFFF59E0B)),
                    ),
                    Expanded(
                      flex: season.losses,
                      child: Container(
                          height: 10, color: const Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _legendDot(const Color(0xFF10B981), 'W ${season.wins}'),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFFF59E0B), 'D ${season.draws}'),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFFEF4444), 'L ${season.losses}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(title: 'Next Match', child: _nextMatchCard()),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Team Info',
          child: Column(
            children: [
              _infoRow(Icons.people_outline, 'Players', '16 active'),
              const Divider(height: 20, color: _gray100),
              _infoRow(Icons.person_outline, 'Staff', '2 members'),
              const Divider(height: 20, color: _gray100),
              _infoRow(Icons.sports_outlined, 'Division', season.division),
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
        Text(label, style: const TextStyle(fontSize: 14, color: _gray500)),
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: _gray500)),
      ],
    );
  }

  Widget _nextMatchCard() {
    final next = events.firstWhere(
        (e) => e.type == EventType.game,
        orElse: () => events.first);
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(next.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _gray900)),
                const SizedBox(height: 3),
                Text(
                    '${_dayAbbr(next.dateTime.weekday)}, ${_monthAbbr(next.dateTime.month)} ${next.dateTime.day} • ${_formatTime(next.dateTime)} • ${next.isHome ? "Home" : "Away"}',
                    style: const TextStyle(fontSize: 12, color: _gray500)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EventDetailScreen(event: next))),
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
        Text(label, style: const TextStyle(fontSize: 14, color: _gray500)),
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
    final coaches =
        _sampleMembers.where((m) => m.jerseyNumber == null).toList();
    final players =
        _sampleMembers.where((m) => m.jerseyNumber != null).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _rosterSection('Coaching Staff', coaches),
        const SizedBox(height: 16),
        _rosterSection('Players', players),
      ],
    );
  }

  Widget _rosterSection(String title, List<_TeamMember> members) {
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
                  const Icon(Icons.chevron_right, color: _gray400, size: 18),
                ],
              ),
              if (!isLast) const Divider(height: 18, color: _gray100),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Schedule Tab ──────────────────────────────────────────────────────────

  Widget _buildScheduleTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: events.map((e) => _scheduleEventTile(e)).toList(),
    );
  }

  Widget _scheduleEventTile(ClubEvent event) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event))),
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
                  color: event.backgroundColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(event.icon, color: event.color, size: 22),
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
                      '${_dayAbbr(event.dateTime.weekday)}, ${_monthAbbr(event.dateTime.month)} ${event.dateTime.day} • ${_formatTime(event.dateTime)}',
                      style: const TextStyle(fontSize: 12, color: _gray500)),
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

// ─── Tab Bar Delegate ─────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(_, __, ___) => Container(color: Colors.white, child: tabBar);

  @override
  bool shouldRebuild(_TabBarDelegate old) => tabBar != old.tabBar;
}
