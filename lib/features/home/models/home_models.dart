// ─── RSVP status ──────────────────────────────────────────────────────────────

enum HomeRsvp { going, maybe, no, none }

// ─── View-Model ───────────────────────────────────────────────────────────────
// Pre-computed per-card data. Widgets receive this and do zero arithmetic.

class HomeCardViewModel {
  final String id;
  final String date;
  final String timeRange;
  final String type;
  final String location;
  final int goingCount;
  final int maybeCount;
  final int noCount;
  final HomeRsvp selectedRsvp;

  const HomeCardViewModel({
    required this.id,
    required this.date,
    required this.timeRange,
    required this.type,
    required this.location,
    required this.goingCount,
    required this.maybeCount,
    required this.noCount,
    required this.selectedRsvp,
  });
}
