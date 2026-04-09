import 'package:flutter/material.dart';

/// Playbook365 — Shared Utilities

// ─── Date / Time Formatting ───────────────────────────────────────────────────

class AppDateUtils {
  AppDateUtils._();

  static const _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _monthNamesShort = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _dayNames = [
    '', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static const _dayNamesShort = [
    '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static String monthName(int month) => _monthNames[month];
  static String monthNameShort(int month) => _monthNamesShort[month];
  static String dayName(int weekday) => _dayNames[weekday];
  static String dayNameShort(int weekday) => _dayNamesShort[weekday];

  static String formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  static String formatTimeOfDay(TimeOfDay t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  static String formatDate(DateTime dt) =>
      '${dayName(dt.weekday)}, ${monthName(dt.month)} ${dt.day}, ${dt.year}';

  static String formatDateShort(DateTime dt) =>
      '${dayNameShort(dt.weekday)}, ${monthNameShort(dt.month)} ${dt.day}';

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.month}/${dt.day}';
  }

  static String chatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final timeStr = formatTime(dt);
    if (diff.inDays == 0) return timeStr;
    if (diff.inDays == 1) return 'Yesterday $timeStr';
    return '${dt.month}/${dt.day} $timeStr';
  }

  static String daySeparatorLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${monthNameShort(dt.month)} ${dt.day}';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());
}

// ─── Shared Widget Helpers ────────────────────────────────────────────────────

class AppWidgetUtils {
  AppWidgetUtils._();

  /// Standard card decoration
  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    double radius = 14,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );

  /// Bottom sheet drag handle
  static Widget dragHandle() => Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  /// Section divider with label
  static Widget sectionDivider(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          ],
        ),
      );
}
