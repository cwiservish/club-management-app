import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_data.dart';
import '../providers/home_provider.dart';
import '../../../core/widgets/shared_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: homeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (data) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTeamBanner(data.stats),
                      const SizedBox(height: 24),
                      _buildQuickStats(data.stats),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Upcoming Events'),
                      const SizedBox(height: 12),
                      ...data.events.map(_buildEventCard),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Announcements'),
                      const SizedBox(height: 12),
                      ...data.announcements.map(_buildAnnouncementCard),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTeamBanner(HomeStats stats) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stats.teamName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  Text(stats.season,
                      style: const TextStyle(
                          color: Color(0xFFBFDBFE), fontSize: 13)),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              _bannerStat('${stats.wins}', 'Wins'),
              Container(width: 1, height: 32, color: Colors.white24),
              _bannerStat('${stats.losses}', 'Losses'),
              Container(width: 1, height: 32, color: Colors.white24),
              _bannerStat('${stats.draws}', 'Draw'),
              Container(width: 1, height: 32, color: Colors.white24),
              _bannerStat(stats.rank, 'Rank'),
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

  Widget _buildQuickStats(HomeStats stats) {
    return Row(
      children: [
        Expanded(
            child: _statCard(Icons.people_outline, '${stats.playerCount}',
                'Players', const Color(0xFF10B981))),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(Icons.calendar_today_outlined,
                '${stats.eventsThisWeek}', 'This Week', const Color(0xFFF59E0B))),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(Icons.chat_bubble_outline,
                '${stats.messageCount}', 'Messages', const Color(0xFF8B5CF6))),
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

  Widget _buildEventCard(HomeEvent event) {
    final isGame = event.type == 'game';
    final color = isGame ? const Color(0xFF1A56DB) : const Color(0xFF10B981);
    final bgColor = isGame ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5);
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

  Widget _buildAnnouncementCard(HomeAnnouncement a) {
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
