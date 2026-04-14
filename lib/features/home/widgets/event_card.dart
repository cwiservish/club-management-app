import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

// ─── RSVP status ──────────────────────────────────────────────────────────────

enum EventRsvp { going, maybe, no, none }

// ─── Color constants (from Figma) ─────────────────────────────────────────────

const _green  = Color(0xFF0ACB97);
const _orange = Color(0xFFFD8F4B);
const _red    = Color(0xFFFF5858);
const _gray   = Color(0xFF4E5663);

// ─── Data model ───────────────────────────────────────────────────────────────

class EventCardData {
  final String date;
  final String timeRange;
  final String type;
  final String location;
  final int goingCount;
  final int maybeCount;
  final int noCount;
  final EventRsvp initialRsvp;

  const EventCardData({
    required this.date,
    required this.timeRange,
    required this.type,
    required this.location,
    this.goingCount  = 0,
    this.maybeCount  = 0,
    this.noCount     = 0,
    this.initialRsvp = EventRsvp.none,
  });
}

// ─── Event Card — StatefulWidget so RSVP buttons are interactive ───────────--

/// Full-width card matching the Figma spec:
/// • White top section: date/time/type/location + interactive Going/Maybe/No buttons
/// • Dark map section at the bottom (full width)
/// • RSVP: tap to select (green/orange/red), tap again to deselect
class EventCard extends StatefulWidget {
  final EventCardData data;
  final VoidCallback? onEventDetails;

  const EventCard({super.key, required this.data, this.onEventDetails});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late EventRsvp _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.data.initialRsvp;
  }

  void _select(EventRsvp rsvp) {
    setState(() {
      // Tap again to deselect
      _selected = _selected == rsvp ? EventRsvp.none : rsvp;
    });
  }

  int get _going  => widget.data.goingCount  + (_selected == EventRsvp.going  ? 1 : 0);
  int get _maybe  => widget.data.maybeCount  + (_selected == EventRsvp.maybe  ? 1 : 0);
  int get _no     => widget.data.noCount     + (_selected == EventRsvp.no     ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── White top section ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                color: colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.data.date,
                        style: AppTextStyles.body16.copyWith(color: colorScheme.onSurface)),
                    Text(widget.data.timeRange,
                        style: AppTextStyles.body16.copyWith(color: colorScheme.onSurface)),
                    Text(widget.data.type,
                        style: AppTextStyles.body16.copyWith(color: colorScheme.onSurface)),
                    Text(widget.data.location,
                        style: AppTextStyles.body16.copyWith(color: colorScheme.onSurface)),

                    const SizedBox(height: 14),

                    // RSVP row — full width, 3 equal buttons
                    _RsvpRow(
                      goingCount: _going,
                      maybeCount: _maybe,
                      noCount:    _no,
                      selected:   _selected,
                      onSelect:   _select,
                    ),

                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: widget.onEventDetails,
                      child: Text(
                        'Event Details',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Dark map section ───────────────────────────────────────────────
              _MapSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── RSVP 3-button row — full width ──────────────────────────────────────────

class _RsvpRow extends StatelessWidget {
  final int goingCount;
  final int maybeCount;
  final int noCount;
  final EventRsvp selected;
  final ValueChanged<EventRsvp> onSelect;

  const _RsvpRow({
    required this.goingCount,
    required this.maybeCount,
    required this.noCount,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RsvpBtn(
            label:    '$goingCount Going',
            activeColor: _green,
            isActive: selected == EventRsvp.going,
            radius:   const BorderRadius.only(
              topLeft:    Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            hasDivider: true,
            onTap:    () => onSelect(EventRsvp.going),
          ),
        ),
        Expanded(
          child: _RsvpBtn(
            label:    '$maybeCount Maybe',
            activeColor: _orange,
            isActive: selected == EventRsvp.maybe,
            radius:   BorderRadius.zero,
            hasDivider: true,
            onTap:    () => onSelect(EventRsvp.maybe),
          ),
        ),
        Expanded(
          child: _RsvpBtn(
            label:    '$noCount No',
            activeColor: _red,
            isActive: selected == EventRsvp.no,
            radius:   const BorderRadius.only(
              topRight:    Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            hasDivider: false,
            onTap:    () => onSelect(EventRsvp.no),
          ),
        ),
      ],
    );
  }
}

// ─── Single RSVP button ───────────────────────────────────────────────────────

class _RsvpBtn extends StatelessWidget {
  final String label;
  final Color activeColor;
  final bool isActive;
  final BorderRadius radius;
  final bool hasDivider;
  final VoidCallback onTap;

  const _RsvpBtn({
    required this.label,
    required this.activeColor,
    required this.isActive,
    required this.radius,
    required this.hasDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? activeColor : _gray;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        height: 37,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: hasDivider
              ? const Border(
                  right: BorderSide(color: Color(0xFFF4F4F4), width: 2),
                )
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─── Map placeholder (bottom of card) ────────────────────────────────────────

class _MapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 134,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFF1E2533)),
          ),
          CustomPaint(painter: _MapGridPainter(), child: const SizedBox.expand()),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_pin, color: Colors.white54, size: 28),
                SizedBox(height: 4),
                Text('Map', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final light  = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 1;
    final road   = Paint()..color = Colors.white.withOpacity(0.12)..strokeWidth = 3;

    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), light);
    }
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), light);
    }
    canvas.drawLine(Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.55), road);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.45, size.height), road);
  }

  @override
  bool shouldRepaint(_) => false;
}
