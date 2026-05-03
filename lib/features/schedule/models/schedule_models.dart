import '../../../core/models/club_event.dart';

// ─── RSVP Status ──────────────────────────────────────────────────────────────

enum RsvpStatus { accepted, declined, unknown }

// ─── Month Section ────────────────────────────────────────────────────────────
// Pre-computed grouping returned by ScheduleState.monthSections.
// The page renders this directly — no logic needed in the UI layer.

class ScheduleMonthSection {
  final String monthName;
  final DateTime monthDate;
  final List<ClubEvent> events;

  const ScheduleMonthSection({
    required this.monthName,
    required this.monthDate,
    required this.events,
  });
}
