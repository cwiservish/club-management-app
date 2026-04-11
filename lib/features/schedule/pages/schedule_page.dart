import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/club_event.dart';
import '../../../core/enums/event_type.dart';
import '../providers/schedule_provider.dart';

const _blue = Color(0xFF1A56DB);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFF59E0B);
const _purple = Color(0xFF8B5CF6);
const _gray50 = Color(0xFFF9FAFB);
const _gray100 = Color(0xFFF3F4F6);
const _gray400 = Color(0xFF9CA3AF);
const _gray500 = Color(0xFF6B7280);
const _gray700 = Color(0xFF374151);
const _gray900 = Color(0xFF111827);

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);
    final notifier = ref.read(scheduleProvider.notifier);

    return Scaffold(
      backgroundColor: _gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state, notifier),
            _buildViewToggle(state, notifier),
            if (state.monthView)
              _buildMonthGrid(state, notifier)
            else
              _buildWeekStrip(state, notifier),
            _buildFilterChips(state, notifier),
            Expanded(child: _buildEventList(context, state)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventSheet(context),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(ScheduleState state, ScheduleNotifier notifier) {
    final monthLabel =
        '${_monthName(state.displayMonth.month)} ${state.displayMonth.year}';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('Schedule',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _gray900)),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: notifier.prevMonth,
                child: const Icon(Icons.chevron_left, color: _gray500),
              ),
              const SizedBox(width: 4),
              Text(monthLabel,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _gray700)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: notifier.nextMonth,
                child: const Icon(Icons.chevron_right, color: _gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(ScheduleState state, ScheduleNotifier notifier) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _toggleBtn('Week', !state.monthView, () => notifier.setMonthView(false)),
          const SizedBox(width: 8),
          _toggleBtn('Month', state.monthView, () => notifier.setMonthView(true)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _blue : _gray100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _gray500)),
      ),
    );
  }

  Widget _buildWeekStrip(ScheduleState state, ScheduleNotifier notifier) {
    final days = state.weekDays;
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final day = days[i];
          final isSelected = day.day == state.selectedDate.day &&
              day.month == state.selectedDate.month &&
              day.year == state.selectedDate.year;
          final isToday = day.day == DateTime.now().day &&
              day.month == DateTime.now().month &&
              day.year == DateTime.now().year;
          final hasEvents = state.eventsForDate(day).isNotEmpty;

          return GestureDetector(
            onTap: () => notifier.selectDate(day),
            child: Column(
              children: [
                Text(dayNames[i],
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? _blue : _gray400,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? _blue : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: _blue, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text('${day.day}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? _blue
                                    : _gray700)),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: hasEvents ? _blue : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthGrid(ScheduleState state, ScheduleNotifier notifier) {
    final firstDay =
        DateTime(state.displayMonth.year, state.displayMonth.month, 1);
    final daysInMonth =
        DateTime(state.displayMonth.year, state.displayMonth.month + 1, 0).day;
    final startOffset = (firstDay.weekday - 1) % 7;
    const headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: headers
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _gray400)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, index) {
              if (index < startOffset) return const SizedBox();
              final dayNum = index - startOffset + 1;
              final date = DateTime(
                  state.displayMonth.year, state.displayMonth.month, dayNum);
              final isSelected = date.day == state.selectedDate.day &&
                  date.month == state.selectedDate.month &&
                  date.year == state.selectedDate.year;
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;
              final hasEvents = state.eventsForDate(date).isNotEmpty;

              return GestureDetector(
                onTap: () {
                  notifier.selectDate(date);
                  notifier.setMonthView(false);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? _blue : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday && !isSelected
                            ? Border.all(color: _blue, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text('$dayNum',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? _blue
                                        : _gray700)),
                      ),
                    ),
                    if (hasEvents)
                      Positioned(
                        bottom: 2,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white70 : _blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ScheduleState state, ScheduleNotifier notifier) {
    final chips = [
      (null, 'All', _blue),
      (EventType.game, 'Games', _blue),
      (EventType.practice, 'Practices', _green),
      (EventType.other, 'Other', _purple),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((chip) {
            final isActive = state.filter == chip.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => notifier.setFilter(chip.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? chip.$3.withOpacity(0.12) : _gray100,
                    borderRadius: BorderRadius.circular(20),
                    border: isActive
                        ? Border.all(color: chip.$3, width: 1.5)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Text(chip.$2,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive ? chip.$3 : _gray500)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context, ScheduleState state) {
    final Map<String, List<ClubEvent>> grouped = {};
    for (final e in state.filtered) {
      final key =
          '${e.dateTime.year}-${e.dateTime.month}-${e.dateTime.day}';
      grouped.putIfAbsent(key, () => []).add(e);
    }

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 48, color: _gray400),
            const SizedBox(height: 12),
            const Text('No events found',
                style: TextStyle(
                    color: _gray500,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            const Text('Tap + to add an event',
                style: TextStyle(color: _gray400, fontSize: 13)),
          ],
        ),
      );
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: sortedKeys.length,
      itemBuilder: (_, i) {
        final key = sortedKeys[i];
        final events = grouped[key]!;
        final date = events.first.dateTime;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            const SizedBox(height: 8),
            ...events.map((e) => _buildEventCard(context, e)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final today = DateTime.now();
    final isToday = date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;
    final label = isToday
        ? 'Today — ${_dayName(date.weekday)}, ${_monthName(date.month)} ${date.day}'
        : '${_dayName(date.weekday)}, ${_monthName(date.month)} ${date.day}';

    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isToday ? _blue : _gray500)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: _gray100, thickness: 1.5)),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, ClubEvent event) {
    final timeStr = _formatTime(event.dateTime);
    final endStr = _formatTime(event.endTime);

    return GestureDetector(
      onTap: () => _showEventDetail(context, event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: event.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(event.icon, color: event.color, size: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(event.title,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _gray900)),
                          ),
                          if (event.rsvpRequired)
                            Container(
                              margin: const EdgeInsets.only(right: 14),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _amber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('RSVP',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _amber)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(event.subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: _gray500)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 13, color: _gray400),
                          const SizedBox(width: 4),
                          Text('$timeStr – $endStr',
                              style: const TextStyle(
                                  fontSize: 12, color: _gray500)),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: _gray400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(event.location,
                                style: const TextStyle(
                                    fontSize: 12, color: _gray500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      if (event.type == EventType.game &&
                          event.opponent != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: event.isHome
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFFF7ED),
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
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.chevron_right, color: _gray400, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetail(BuildContext context, ClubEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _gray100, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: event.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(event.icon, color: event.color, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(height: 4),
                              Text(event.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: _gray900)),
                              Text(event.subtitle,
                                  style: const TextStyle(
                                      fontSize: 13, color: _gray500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _detailRow(Icons.calendar_today_outlined,
                        '${_dayName(event.dateTime.weekday)}, ${_monthName(event.dateTime.month)} ${event.dateTime.day}, ${event.dateTime.year}'),
                    const SizedBox(height: 12),
                    _detailRow(Icons.access_time,
                        '${_formatTime(event.dateTime)} – ${_formatTime(event.endTime)} (${event.duration.inMinutes} min)'),
                    const SizedBox(height: 12),
                    _detailRow(Icons.location_on_outlined, event.location),
                    if (event.type == EventType.game &&
                        event.opponent != null) ...[
                      const SizedBox(height: 12),
                      _detailRow(Icons.sports_soccer,
                          '${event.isHome ? "Home" : "Away"} vs. ${event.opponent}'),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _blue,
                              side: const BorderSide(color: _blue),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.check_circle_outline,
                                size: 16),
                            label: const Text('RSVP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
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
    );
  }

  void _showAddEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _gray100,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Add Event',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _gray900)),
              const SizedBox(height: 16),
              _formField('Event Title', 'e.g. Team Practice'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _formField('Date', 'Mar 29, 2026')),
                  const SizedBox(width: 12),
                  Expanded(child: _formField('Time', '10:00 AM')),
                ],
              ),
              const SizedBox(height: 12),
              _formField('Location', 'Field, address…'),
              const SizedBox(height: 12),
              const Text('Type',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _gray700)),
              const SizedBox(height: 8),
              Row(
                children: EventType.values.map((t) {
                  final color = t == EventType.game
                      ? _blue
                      : t == EventType.practice
                          ? _green
                          : _purple;
                  final bg = t == EventType.game
                      ? const Color(0xFFEFF6FF)
                      : t == EventType.practice
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF5F3FF);
                  final icon = t == EventType.game
                      ? Icons.sports_soccer
                      : t == EventType.practice
                          ? Icons.fitness_center
                          : Icons.event_note_outlined;
                  final label = t == EventType.game
                      ? 'Game'
                      : t == EventType.practice
                          ? 'Practice'
                          : 'Other';

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: t != EventType.other ? 8 : 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(icon, color: color, size: 20),
                            const SizedBox(height: 4),
                            Text(label,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Event',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _gray700)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _gray400, fontSize: 14),
            filled: true,
            fillColor: _gray50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _gray100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const names = [
      '',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[m];
  }

  String _dayName(int weekday) {
    const names = [
      '',
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return names[weekday];
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }
}
