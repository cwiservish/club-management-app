import 'package:flutter/material.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  final Map<String, bool> _prefs = {
    'Game Reminders': true,
    'Practice Reminders': true,
    'New Messages': true,
    'RSVP Requests': true,
    'Team Announcements': true,
    'Invoice Reminders': false,
    'Photo Uploads': false,
    'File Shares': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _prefGroup('Events',
              ['Game Reminders', 'Practice Reminders', 'RSVP Requests']),
          const SizedBox(height: 16),
          _prefGroup('Communication', ['New Messages', 'Team Announcements']),
          const SizedBox(height: 16),
          _prefGroup('Finance & Files',
              ['Invoice Reminders', 'Photo Uploads', 'File Shares']),
        ],
      ),
    );
  }

  Widget _prefGroup(String title, List<String> keys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: keys.asMap().entries.map((e) {
              final isLast = e.key == keys.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(e.value,
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF374151))),
                        ),
                        Switch(
                          value: _prefs[e.value] ?? false,
                          onChanged: (v) =>
                              setState(() => _prefs[e.value] = v),
                          activeColor: const Color(0xFF1A56DB),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1, indent: 16, color: Color(0xFFF3F4F6)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
