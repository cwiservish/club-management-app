import '../../../core/models/club_event.dart';

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
  final bool isLoadingRsvp;
  final String? latitude;
  final String? longitude;
  final bool requiresPlayerSelection;
  final List<ClubEventRsvpTarget> rsvpTargets;
  final int? scheduleGameId;
  final String? homeAwayLabel;
  final String? eventName;

  /// Status 5: a coach's session waiting for a manager to confirm it.
  final bool isDraft;

  /// Server `can_rsvp`: false hides the RSVP buttons' interactivity.
  final bool canRsvp;

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
    this.isLoadingRsvp = false,
    this.latitude,
    this.longitude,
    this.requiresPlayerSelection = false,
    this.rsvpTargets = const [],
    this.scheduleGameId,
    this.homeAwayLabel,
    this.eventName,
    this.isDraft = false,
    this.canRsvp = true,
  });
}
