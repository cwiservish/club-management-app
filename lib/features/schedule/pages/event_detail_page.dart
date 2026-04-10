import 'package:flutter/material.dart';

import '../../../core/models/club_event.dart';
import '../../../core/models/sample_data.dart';
import '../../../core/enums/event_type.dart';
import 'event_form_page.dart';

// ─── Local colour palette ─────────────────────────────────────────────────────

const _green = Color(0xFF10B981);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFEF4444);
const _gray50 = Color(0xFFF9FAFB);
const _gray100 = Color(0xFFF3F4F6);
const _gray400 = Color(0xFF9CA3AF);
const _gray500 = Color(0xFF6B7280);
const _gray700 = Color(0xFF374151);
const _gray900 = Color(0xFF111827);

// ─── Date/time helpers ────────────────────────────────────────────────────────

String _monthName(int m) => const [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][m];

String _dayName(int weekday) => const [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ][weekday];

String _formatTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
}

// ══════════════════════════════════════════════════════════════════════════════
// EVENT DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class EventDetailScreen extends StatefulWidget {
  final ClubEvent? event;
  const EventDetailScreen({super.key, this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String? _myRsvp; // 'yes' | 'no' | 'maybe'

  ClubEvent get event => widget.event ?? sampleEvents.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gray50,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventHeader(),
                  const SizedBox(height: 16),
                  _buildDetailsCard(),
                  const SizedBox(height: 16),
                  if (event.notes != null) ...[
                    _buildNotesCard(),
                    const SizedBox(height: 16),
                  ],
                  if (event.rsvpRequired) ...[
                    _buildRsvpCard(),
                    const SizedBox(height: 16),
                    _buildAttendanceCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: event.color,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        event.typeLabel,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => EventFormScreen(event: event))),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showMoreMenu(),
        ),
      ],
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: event.backgroundColor,
                borderRadius: BorderRadius.circular(14)),
            child: Icon(event.icon, color: event.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.typeLabel.toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: event.color),
                      ),
                    ),
                    if (event.type == EventType.game) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: event.isHome
                              ? _green.withOpacity(0.1)
                              : _amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.isHome ? 'HOME' : 'AWAY',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: event.isHome ? _green : _amber),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _gray900),
                ),
                Text(event.subtitle,
                    style: const TextStyle(fontSize: 13, color: _gray500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _detailCard(
      title: 'Event Details',
      children: [
        _detailRow(
            Icons.calendar_today_outlined,
            '${_dayName(event.dateTime.weekday)}, ${_monthName(event.dateTime.month)} ${event.dateTime.day}, ${event.dateTime.year}'),
        _detailRow(Icons.access_time,
            '${_formatTime(event.dateTime)} – ${_formatTime(event.endTime)} (${event.duration.inMinutes} min)'),
        _detailRow(Icons.location_on_outlined, event.location),
        if (event.opponent != null)
          _detailRow(Icons.sports_soccer,
              'vs. ${event.opponent} (${event.isHome ? "Home" : "Away"})'),
      ],
    );
  }

  Widget _buildNotesCard() {
    return _detailCard(
      title: 'Notes',
      children: [
        Text(event.notes!,
            style: const TextStyle(
                fontSize: 14, color: _gray700, height: 1.5)),
      ],
    );
  }

  Widget _buildRsvpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your RSVP',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _gray900)),
          const SizedBox(height: 14),
          Row(
            children: [
              _rsvpBtn('yes', 'Going', Icons.check_circle_outline, _green),
              const SizedBox(width: 8),
              _rsvpBtn('no', "Can't Go", Icons.cancel_outlined, _red),
              const SizedBox(width: 8),
              _rsvpBtn('maybe', 'Maybe', Icons.help_outline, _amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rsvpBtn(String value, String label, IconData icon, Color color) {
    final isSelected = _myRsvp == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _myRsvp = isSelected ? null : value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : _gray100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : _gray400, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : _gray500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final yes = event.rsvpYes;
    final no = event.rsvpNo;
    final maybe = event.rsvpMaybe;
    final total = yes.length + no.length + maybe.length;

    return _detailCard(
      title: 'Team Attendance ($total)',
      children: [
        Row(
          children: [
            _attendanceChip(yes.length, 'Going', _green),
            const SizedBox(width: 8),
            _attendanceChip(maybe.length, 'Maybe', _amber),
            const SizedBox(width: 8),
            _attendanceChip(no.length, "Can't Go", _red),
          ],
        ),
        const SizedBox(height: 14),
        if (yes.isNotEmpty) ...[
          _rsvpGroup('Going', yes, _green),
          const SizedBox(height: 10),
        ],
        if (maybe.isNotEmpty) ...[
          _rsvpGroup('Maybe', maybe, _amber),
          const SizedBox(height: 10),
        ],
        if (no.isNotEmpty) _rsvpGroup("Can't Go", no, _red),
      ],
    );
  }

  Widget _attendanceChip(int count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: _gray500)),
          ],
        ),
      ),
    );
  }

  Widget _rsvpGroup(String title, List<String> names, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: names
              .map((n) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gray100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(n,
                        style:
                            const TextStyle(fontSize: 12, color: _gray700)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EventFormScreen(event: event))),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit Event'),
            style: OutlinedButton.styleFrom(
              foregroundColor: event.color,
              side: BorderSide(color: event.color),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: event.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _gray900)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _gray400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, color: _gray700, height: 1.4)),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _gray100,
                    borderRadius: BorderRadius.circular(2))),
            _menuItem(
                Icons.content_copy_outlined, 'Duplicate Event', _gray700),
            _menuItem(
                Icons.notifications_outlined, 'Send Reminder', _gray700),
            _menuItem(Icons.delete_outline, 'Delete Event', _red),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color)),
      onTap: () => Navigator.pop(context),
    );
  }
}
