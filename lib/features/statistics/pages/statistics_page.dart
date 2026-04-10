import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tab,
          labelColor: const Color(0xFF1A56DB),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF1A56DB),
          tabs: const [Tab(text: 'Team'), Tab(text: 'Players')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildTeamStats(),
          _buildPlayerStats(),
        ],
      ),
    );
  }

  Widget _buildTeamStats() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statCard('Season Record', [
          _statRow('Wins', '8', const Color(0xFF10B981)),
          _statRow('Losses', '2', const Color(0xFFEF4444)),
          _statRow('Draws', '1', const Color(0xFFF59E0B)),
          _statRow('Win Rate', '73%', const Color(0xFF1A56DB)),
        ]),
        const SizedBox(height: 16),
        _statCard('Goals', [
          _statRow('Scored', '27', const Color(0xFF10B981)),
          _statRow('Conceded', '11', const Color(0xFFEF4444)),
          _statRow('Difference', '+16', const Color(0xFF1A56DB)),
          _statRow('Per Game Avg', '2.45', const Color(0xFF8B5CF6)),
        ]),
        const SizedBox(height: 16),
        _statCard('Discipline', [
          _statRow('Yellow Cards', '9', const Color(0xFFF59E0B)),
          _statRow('Red Cards', '1', const Color(0xFFEF4444)),
        ]),
      ],
    );
  }

  Widget _buildPlayerStats() {
    const players = [
      ('James Miller', '#9 FWD', 9, 4, 3),
      ('Oliver Davis', '#10 MID', 5, 8, 0),
      ('Lucas Wilson', '#11 FWD', 6, 3, 1),
      ('Henry Thomas', '#6 MID', 4, 6, 0),
      ('Ethan Brown', '#5 DEF', 2, 2, 1),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('Player',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280)))),
              Expanded(
                  child: Text('G',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280)))),
              Expanded(
                  child: Text('A',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280)))),
              Expanded(
                  child: Text('YC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280)))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...players.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.$1,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827))),
                        Text(p.$2,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Text('${p.$3}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981)))),
                  Expanded(
                      child: Text('${p.$4}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A56DB)))),
                  Expanded(
                      child: Text('${p.$5}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B)))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _statCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
