import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_prefs_provider.dart';

class NotificationPrefsScreen extends ConsumerWidget {
  const NotificationPrefsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notifPrefsProvider);
    final notifier = ref.read(notifPrefsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _prefGroup('Events',
              ['Game Reminders', 'Practice Reminders', 'RSVP Requests'],
              prefs, notifier),
          const SizedBox(height: 16),
          _prefGroup('Communication', ['New Messages', 'Team Announcements'],
              prefs, notifier),
          const SizedBox(height: 16),
          _prefGroup('Finance & Files',
              ['Invoice Reminders', 'Photo Uploads', 'File Shares'],
              prefs, notifier),
        ],
      ),
    );
  }

  Widget _prefGroup(
    String title,
    List<String> keys,
    Map<String, bool> prefs,
    NotifPrefsNotifier notifier,
  ) {
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
                          value: prefs[e.value] ?? false,
                          onChanged: (_) => notifier.toggle(e.value),
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
