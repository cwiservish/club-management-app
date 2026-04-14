import 'package:flutter/material.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../widgets/event_card.dart';

// ─── Sample event data ────────────────────────────────────────────────────────

const _events = [
  EventCardData(
    date:       'February 17, 2026',
    timeRange:  '6:00 - 7:30 PM',
    type:       'Practice',
    location:   'Gillis-Rother Soccer Complex',
    goingCount: 11,
    maybeCount: 0,
    noCount:    0,
    initialRsvp: EventRsvp.going,
  ),
  EventCardData(
    date:       'February 17, 2026',
    timeRange:  '6:00 - 7:30 PM',
    type:       'Practice',
    location:   'Gillis-Rother Soccer Complex',
    goingCount: 11,
    maybeCount: 2,
    noCount:    0,
    initialRsvp: EventRsvp.maybe,
  ),
  EventCardData(
    date:       'February 17, 2026',
    timeRange:  '6:00 - 7:30 PM',
    type:       'Practice',
    location:   'Gillis-Rother Soccer Complex',
    goingCount: 11,
    maybeCount: 0,
    noCount:    1,
    initialRsvp: EventRsvp.no,
  ),
];

// ─── Events Screen ────────────────────────────────────────────────────────────

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest, // #F4F4F4 gap bg
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _events.length,
                // Thin #F4F4F4 divider between cards — matches the Figma background
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => EventCard(
                  data: _events[i],
                  onEventDetails: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
