import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/club_event.dart';
import '../../../core/enums/event_type.dart';

// ─── Local colour palette ─────────────────────────────────────────────────────

const _blue = Color(0xFF1A56DB);
const _gray50 = Color(0xFFF9FAFB);
const _gray100 = Color(0xFFF3F4F6);
const _gray200 = Color(0xFFE5E7EB);
const _gray400 = Color(0xFF9CA3AF);
const _gray500 = Color(0xFF6B7280);
const _gray700 = Color(0xFF374151);
const _gray900 = Color(0xFF111827);
const _red = Color(0xFFEF4444);

// ─── EventType helpers (needed for type-based colour before a ClubEvent exists) ─

Color _colorFor(EventType t) {
  switch (t) {
    case EventType.game:     return const Color(0xFF1A56DB);
    case EventType.practice: return const Color(0xFF10B981);
    case EventType.other:    return const Color(0xFF8B5CF6);
  }
}

Color _bgFor(EventType t) {
  switch (t) {
    case EventType.game:     return const Color(0xFFEFF6FF);
    case EventType.practice: return const Color(0xFFECFDF5);
    case EventType.other:    return const Color(0xFFF5F3FF);
  }
}

IconData _iconFor(EventType t) {
  switch (t) {
    case EventType.game:     return Icons.sports_soccer;
    case EventType.practice: return Icons.fitness_center;
    case EventType.other:    return Icons.event_note_outlined;
  }
}

String _labelFor(EventType t) {
  switch (t) {
    case EventType.game:     return 'Game';
    case EventType.practice: return 'Practice';
    case EventType.other:    return 'Other';
  }
}

// ─── Date/time helpers ────────────────────────────────────────────────────────

String _monthName(int m) => const [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][m];

String _dayName(int weekday) => const [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ][weekday];

// ══════════════════════════════════════════════════════════════════════════════
// EVENT FORM SCREEN (Add / Edit)
// ══════════════════════════════════════════════════════════════════════════════

class EventFormScreen extends StatefulWidget {
  final ClubEvent? event; // null = Add mode, non-null = Edit mode

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  bool get isEdit => widget.event != null;

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _opponentController = TextEditingController();

  EventType _eventType = EventType.game;
  bool _isHome = true;
  bool _rsvpRequired = false;
  DateTime _selectedDate = DateTime(2026, 3, 29);
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final e = widget.event!;
      _titleController.text = e.title;
      _locationController.text = e.location;
      _notesController.text = e.notes ?? '';
      _opponentController.text = e.opponent ?? '';
      _eventType = e.type;
      _isHome = e.isHome;
      _rsvpRequired = e.rsvpRequired;
      _selectedDate = e.dateTime;
      _startTime =
          TimeOfDay(hour: e.dateTime.hour, minute: e.dateTime.minute);
      final end = e.dateTime.add(e.duration);
      _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _opponentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _gray700),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          isEdit ? 'Edit Event' : 'New Event',
          style: const TextStyle(
              color: _gray900,
              fontSize: 17,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventTypeSelector(),
            const SizedBox(height: 16),
            _buildFormCard(children: [
              _field('Event Title', _titleController,
                  hint: 'e.g. vs. Riverside FC', icon: Icons.title),
              const Divider(height: 1, color: _gray100),
              _field('Location', _locationController,
                  hint: 'Field, address…',
                  icon: Icons.location_on_outlined),
            ]),
            const SizedBox(height: 16),
            _buildFormCard(children: [
              _datePicker(),
              const Divider(height: 1, color: _gray100),
              _timePicker('Start Time', _startTime,
                  (t) => setState(() => _startTime = t)),
              const Divider(height: 1, color: _gray100),
              _timePicker('End Time', _endTime,
                  (t) => setState(() => _endTime = t)),
            ]),
            if (_eventType == EventType.game) ...[
              const SizedBox(height: 16),
              _buildFormCard(children: [
                _field('Opponent', _opponentController,
                    hint: 'Team name…', icon: Icons.sports_soccer),
                const Divider(height: 1, color: _gray100),
                _homeAwayToggle(),
              ]),
            ],
            const SizedBox(height: 16),
            _buildFormCard(children: [
              _rsvpToggleRow(),
              const Divider(height: 1, color: _gray100),
              _field('Notes', _notesController,
                  hint: 'Add any notes for the team…',
                  icon: Icons.notes_outlined,
                  maxLines: 3),
            ]),
            const SizedBox(height: 24),
            _buildSaveButton(),
            if (isEdit) ...[
              const SizedBox(height: 12),
              _buildDeleteButton(),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Event Type Selector ───────────────────────────────────────────────────

  Widget _buildEventTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Type',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _gray700)),
        const SizedBox(height: 10),
        Row(
          children: EventType.values.map((t) {
            final isActive = _eventType == t;
            final color = _colorFor(t);
            final bg = _bgFor(t);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: t != EventType.other ? 10 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _eventType = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isActive ? bg : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? color : _gray200,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                  color: color.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(_iconFor(t),
                            color: isActive ? color : _gray400,
                            size: 22),
                        const SizedBox(height: 6),
                        Text(_labelFor(t),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isActive ? color : _gray500)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Form Card ─────────────────────────────────────────────────────────────

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── Text Field ────────────────────────────────────────────────────────────

  Widget _field(String label, TextEditingController controller,
      {String hint = '', IconData? icon, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 14 : 0),
              child: Icon(icon, size: 18, color: _gray400),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 14, color: _gray900),
              decoration: InputDecoration(
                labelText: label,
                labelStyle:
                    const TextStyle(fontSize: 13, color: _gray400),
                hintText: hint,
                hintStyle:
                    const TextStyle(fontSize: 14, color: _gray400),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Picker ───────────────────────────────────────────────────────────

  Widget _datePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2026),
          lastDate: DateTime(2027),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme:
                  const ColorScheme.light(primary: _blue),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: _gray400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date',
                      style: TextStyle(fontSize: 12, color: _gray400)),
                  const SizedBox(height: 2),
                  Text(
                    '${_dayName(_selectedDate.weekday)}, ${_monthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}',
                    style: const TextStyle(
                        fontSize: 14,
                        color: _gray900,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: _gray400),
          ],
        ),
      ),
    );
  }

  // ── Time Picker ───────────────────────────────────────────────────────────

  Widget _timePicker(
      String label, TimeOfDay time, ValueChanged<TimeOfDay> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme:
                  const ColorScheme.light(primary: _blue),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 18, color: _gray400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: _gray400)),
                  const SizedBox(height: 2),
                  Text(
                    time.format(context),
                    style: const TextStyle(
                        fontSize: 14,
                        color: _gray900,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: _gray400),
          ],
        ),
      ),
    );
  }

  // ── Home / Away Toggle ────────────────────────────────────────────────────

  Widget _homeAwayToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18, color: _gray400),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Venue',
                style: TextStyle(fontSize: 14, color: _gray700)),
          ),
          Container(
            decoration: BoxDecoration(
              color: _gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _venueBtn('Home', true),
                _venueBtn('Away', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _venueBtn(String label, bool isHomeValue) {
    final isActive = _isHome == isHomeValue;
    return GestureDetector(
      onTap: () => setState(() => _isHome = isHomeValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4)
                ]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? _blue : _gray400)),
      ),
    );
  }

  // ── RSVP Toggle ───────────────────────────────────────────────────────────

  Widget _rsvpToggleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.how_to_reg_outlined,
              size: 18, color: _gray400),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RSVP Required',
                    style: TextStyle(fontSize: 14, color: _gray700)),
                Text('Players must respond to this event',
                    style: TextStyle(fontSize: 11, color: _gray400)),
              ],
            ),
          ),
          Switch(
            value: _rsvpRequired,
            onChanged: (v) => setState(() => _rsvpRequired = v),
            activeColor: _blue,
          ),
        ],
      ),
    );
  }

  // ── Save / Delete Buttons ─────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          isEdit ? 'Save Changes' : 'Create Event',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _confirmDelete,
        style: OutlinedButton.styleFrom(
          foregroundColor: _red,
          side: const BorderSide(color: _red),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Delete Event',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _save() => Navigator.maybePop(context);

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Event',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to delete this event? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel',
                style: TextStyle(color: _gray500)),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // close dialog
              if (context.canPop()) context.pop(); // close form
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
