import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/event_type.dart';
import '../models/home_models.dart';
import '../services/home_service.dart';

export '../models/home_models.dart';

// ─── Notifier ─────────────────────────────────────────────────────────────────

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState(
      events:    ref.read(homeServiceProvider).getEvents(),
      userRsvps: const {},
    );
  }

  /// Toggle RSVP: tapping the same option again deselects it.
  void toggleRsvp(String eventId, HomeRsvp rsvp) {
    final current = state.userRsvps[eventId] ?? HomeRsvp.none;
    final next    = current == rsvp ? HomeRsvp.none : rsvp;

    state = state.copyWith(
      userRsvps: {...state.userRsvps, eventId: next},
    );
  }

  void setFilter(EventType? f) => state = state.copyWith(filter: f);
}

// ─── Providers ────────────────────────────────────────────────────────────────

final homeServiceProvider =
    Provider<HomeService>((ref) => HomeService());

final homeProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
