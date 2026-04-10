import 'package:flutter/material.dart';

// Local data models (home-screen specific, not shared)
class _UpcomingEvent {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String type;

  const _UpcomingEvent({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.type,
  });
}

class _TeamAnnouncement {
  final String message;
  final String author;
  final String timeAgo;
  final String avatarInitials;

  const _TeamAnnouncement({
    required this.message,
    required this.author,
    required this.timeAgo,
    required this.avatarInitials,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _events = [
    _UpcomingEvent(
      title: 'vs. Riverside FC',
      subtitle: 'U14 Boys — Home Game',
      date: 'Sat, Mar 29',
      time: '10:00 AM',
      type: 'game',
    ),
    _UpcomingEvent(
      title: 'Team Practice',
      subtitle: 'U14 Boys — Field 3',
      date: 'Wed, Mar 26',
      time: '5:30 PM',
      type: 'practice',
    ),
    _UpcomingEvent(
      title: 'vs. Eagles SC',
      subtitle: 'U14 Boys — Away Game',
      date: 'Sat, Apr 5',
      time: '2:00 PM',
      type: 'game',
    ),
  ];

  static const _announcements = [
    _TeamAnnouncement(
      message: 'Reminder: Bring your shin guards and cleats to practice tomorrow.',
      author: 'Coach Martinez',
      timeAgo: '2h ago',
      avatarInitials: 'CM',
    ),
    _TeamAnnouncement(
      message: 'Registration deadline for the spring tournament is this Friday!',
      author: 'Club Admin',
      timeAgo: '1d ago',
      avatarInitials: 'CA',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTeamBanner(),
                    const SizedBox(height: 24),
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Upcoming Events'),
                    const SizedBox(height: 12),
                    ..._events.map(_buildEventCard),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Announcements'),
                    const SizedBox(height: 12),
                    ..._announcements.map(_buildAnnouncementCard),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A56DB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('P',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Playbook365',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF6B7280)),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFDBEAFE),
            child: Text('JD',
                style: TextStyle(
                    color: Color(0xFF1A56DB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_soccer,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('U14 Boys Premier',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  Text('Spring Season 2025',
                      style: TextStyle(
                          color: Color(0xFFBFDBFE), fontSize: 13)),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Team',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bannerStat('8', 'Wins'),
              Container(width: 1, height: 32, color: Colors.white24),
              _bannerStat('2', 'Losses'),
              Container(width: 1, height: 32, color: Colors.white24),
              _bannerStat('1', 'Draw'),
              Container(width: 1, height: 32, color: Colors.white24),
              _bannerStat('3rd', 'Rank'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
            child: _statCard(Icons.people_outline, '18', 'Players',
                const Color(0xFF10B981))),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(Icons.calendar_today_outlined, '3', 'This Week',
                const Color(0xFFF59E0B))),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(Icons.chat_bubble_outline, '5', 'Messages',
                const Color(0xFF8B5CF6))),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827))),
        const Text('See all',
            style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1A56DB),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEventCard(_UpcomingEvent event) {
    final isGame = event.type == 'game';
    final color = isGame ? const Color(0xFF1A56DB) : const Color(0xFF10B981);
    final bgColor =
        isGame ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5);
    final icon = isGame ? Icons.sports_soccer : Icons.fitness_center;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 4),
                Text(event.date.split(',')[0],
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
                const SizedBox(height: 3),
                Text(event.subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(event.time,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
              const SizedBox(height: 3),
              Text(event.date,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(_TeamAnnouncement a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFDDE3FF),
            child: Text(a.avatarInitials,
                style: const TextStyle(
                    color: Color(0xFF1A56DB),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(a.author,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827))),
                    const Spacer(),
                    Text(a.timeAgo,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(a.message,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _actionButton(
                    Icons.add_circle_outline, 'Add Event', const Color(0xFF1A56DB))),
            const SizedBox(width: 10),
            Expanded(
                child: _actionButton(
                    Icons.person_add_outlined, 'Add Player', const Color(0xFF10B981))),
            const SizedBox(width: 10),
            Expanded(
                child: _actionButton(
                    Icons.receipt_long_outlined, 'Invoice', const Color(0xFFF59E0B))),
            const SizedBox(width: 10),
            Expanded(
                child: _actionButton(
                    Icons.bar_chart_outlined, 'Stats', const Color(0xFF8B5CF6))),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
