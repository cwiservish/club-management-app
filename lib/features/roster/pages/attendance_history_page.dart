import 'package:flutter/material.dart';

class PlayerAttendanceScreen extends StatelessWidget {
  const PlayerAttendanceScreen({super.key});

  static const _data = [
    ('Liam Anderson', 'GK #1', 92, 11, 12),
    ('Noah Williams', 'DEF #4', 88, 10, 12),
    ('Ethan Brown', 'DEF #5', 100, 12, 12),
    ('Mason Jones', 'MID #8', 75, 9, 12),
    ('Oliver Davis', 'MID #10', 96, 11, 12),
    ('James Miller', 'FWD #9', 83, 10, 12),
    ('Lucas Wilson', 'FWD #11', 91, 11, 12),
    ('Henry Thomas', 'MID #6', 100, 12, 12),
    ('Aiden Taylor', 'DEF #3', 67, 8, 12),
  ];

  static Color _color(int pct) => pct >= 90
      ? const Color(0xFF10B981)
      : pct >= 75
          ? const Color(0xFFF59E0B)
          : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Player Attendance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _data
            .map((p) => Container(
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.$1,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827))),
                                Text(p.$2,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                          Text('${p.$3}',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _color(p.$3))),
                          const Text('%',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF9CA3AF))),
                          const SizedBox(width: 8),
                          Text('${p.$4}/${p.$5}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p.$3 / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_color(p.$3)),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
