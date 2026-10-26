import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class WeeklySlotConfig {
  final String dayName;
  final int weekday; // 1 (Mon) .. 7 (Sun)
  bool isChecked;
  TimeOfDay startTime;
  TimeOfDay endTime;

  WeeklySlotConfig({
    required this.dayName,
    required this.weekday,
    required this.isChecked,
    required this.startTime,
    required this.endTime,
  });
}

class EventRepeatsUntilSection extends StatefulWidget {
  final bool isRepeating;
  final ValueChanged<bool> onRepeatingChanged;
  final String repeatType; // 'Weekly' or 'Monthly'
  final ValueChanged<String> onRepeatTypeChanged;
  final DateTime startDate;
  final ValueChanged<DateTime>? onStartDateChanged;
  final DateTime? repeatUntilDate;
  final ValueChanged<DateTime?> onRepeatUntilDateChanged;
  final List<WeeklySlotConfig> weeklySlots;
  final ValueChanged<List<WeeklySlotConfig>> onWeeklySlotsChanged;
  final Set<DateTime> selectedMonthlyDates; // date-only, picked manually per month
  final ValueChanged<Set<DateTime>> onMonthlyDatesChanged;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onSelectedMonthChanged;
  final TimeOfDay defaultStartTime;
  final TimeOfDay defaultEndTime;

  /// Validation messages (null = fine) and scroll keys for the parent form.
  final String? repeatUntilError;
  final String? daysError;
  final String? datesError;
  final GlobalKey? repeatUntilKey;
  final GlobalKey? daysKey;
  final GlobalKey? datesKey;

  const EventRepeatsUntilSection({
    super.key,
    required this.isRepeating,
    required this.onRepeatingChanged,
    required this.repeatType,
    required this.onRepeatTypeChanged,
    required this.startDate,
    this.onStartDateChanged,
    required this.repeatUntilDate,
    required this.onRepeatUntilDateChanged,
    required this.weeklySlots,
    required this.onWeeklySlotsChanged,
    required this.selectedMonthlyDates,
    required this.onMonthlyDatesChanged,
    required this.selectedMonth,
    required this.onSelectedMonthChanged,
    required this.defaultStartTime,
    required this.defaultEndTime,
    this.repeatUntilError,
    this.daysError,
    this.datesError,
    this.repeatUntilKey,
    this.daysKey,
    this.datesKey,
  });

  @override
  State<EventRepeatsUntilSection> createState() => _EventRepeatsUntilSectionState();
}

class _EventRepeatsUntilSectionState extends State<EventRepeatsUntilSection> {
  static const Color _yellowAccent = Color(0xFFF5BD1F);

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $amPm';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month/$day/$year';
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  DateTime get _minSelectableDate {
    final today = DateUtils.dateOnly(DateTime.now());
    final start = DateUtils.dateOnly(widget.startDate);
    return start.isAfter(today) ? start : today;
  }

  /// No practical upper cap; only past dates are blocked.
  DateTime get _maxSelectableDate => DateTime(2100, 12, 31);


  Future<void> _pickRepeatUntilDate() async {
    final firstDate = _minSelectableDate;
    // Weekly series: server allows at most 1 year after the start date.
    final start = _minSelectableDate;
    final maxDate = DateTime(start.year + 1, start.month, start.day);
    final current = widget.repeatUntilDate;
    var initial = current ?? firstDate.add(const Duration(days: 30));
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(maxDate)) initial = maxDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: maxDate,
    );

    if (picked != null) {
      widget.onRepeatUntilDateChanged(picked);
    }
  }

  Future<void> _pickSlotTime(BuildContext context, int index, bool isStartTime) async {
    final slot = widget.weeklySlots[index];
    final initial = isStartTime ? slot.startTime : slot.endTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          slot.startTime = picked;
        } else {
          slot.endTime = picked;
        }
      });
      widget.onWeeklySlotsChanged(widget.weeklySlots);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final isDark = colors.isDark;

    final borderColor = isDark ? colors.border : const Color(0xFFE5E7EB);
    final inputBg = isDark ? colors.background : const Color(0xFFF4F5F7);
    final cardBg = isDark ? colors.card : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1D20);
    final helperColor = isDark ? colors.textSecondary : const Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Repeats Until Header & Radio Options ──
        Text(
          'Repeats Until',
          style: AppTextStyles.heading15.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // Radio: No
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onRepeatingChanged(false),
              child: Row(
                children: [
                  _buildRadioButton(isSelected: !widget.isRepeating),
                  const SizedBox(width: 8),
                  Text(
                    'No',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Radio: Yes
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onRepeatingChanged(true),
              child: Row(
                children: [
                  _buildRadioButton(isSelected: widget.isRepeating),
                  const SizedBox(width: 8),
                  Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.isRepeating) ...[
              const SizedBox(width: 20),
              // Dropdown: Weekly vs Monthly
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.repeatType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 22),
                      dropdownColor: cardBg,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                      ],
                      onChanged: (val) {
                        if (val != null) widget.onRepeatTypeChanged(val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        // ── Expandable Repeat Body ──
        if (widget.isRepeating) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: widget.repeatType == 'Weekly'
                ? _buildWeeklyView(
                    context,
                    titleColor: titleColor,
                    helperColor: helperColor,
                    borderColor: borderColor,
                    inputBg: inputBg,
                  )
                : _buildMonthlyView(
                    context,
                    titleColor: titleColor,
                    helperColor: helperColor,
                    borderColor: borderColor,
                    inputBg: inputBg,
                    cardBg: cardBg,
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildRadioButton({required bool isSelected}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? _yellowAccent : const Color(0xFFD1D5DB),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _yellowAccent,
                ),
              ),
            )
          : null,
    );
  }

  // ── Weekly View (Screenshots 2) ─────────────────────────────────────────────
  Widget _buildWeeklyView(
    BuildContext context, {
    required Color titleColor,
    required Color helperColor,
    required Color borderColor,
    required Color inputBg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Repeat Until Row
        Row(
          key: widget.repeatUntilKey,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                'Repeat Until:',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _pickRepeatUntilDate,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.repeatUntilError != null ? const Color(0xFFFDECEA) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.repeatUntilError != null ? const Color(0xFFD32F2F) : borderColor,
                      width: widget.repeatUntilError != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 17, color: helperColor),
                      const SizedBox(width: 8),
                      Text(
                        widget.repeatUntilDate != null
                            ? _formatDate(widget.repeatUntilDate!)
                            : 'Select date',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: widget.repeatUntilDate != null ? FontWeight.w700 : FontWeight.w500,
                          color: widget.repeatUntilDate != null ? titleColor : helperColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.repeatUntilError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 110),
            child: Text(widget.repeatUntilError!,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFFD32F2F))),
          ),
        const SizedBox(height: 16),

        // 7 Weekly Slots (Mon to Sun)
        if (widget.daysError != null)
          Padding(
            key: widget.daysKey,
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.daysError!,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
          ),
        for (int i = 0; i < widget.weeklySlots.length; i++) ...[
          _buildWeeklySlotRow(
            context,
            index: i,
            slot: widget.weeklySlots[i],
            titleColor: titleColor,
            borderColor: borderColor,
            inputBg: inputBg,
          ),
          if (i < widget.weeklySlots.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildWeeklySlotRow(
    BuildContext context, {
    required int index,
    required WeeklySlotConfig slot,
    required Color titleColor,
    required Color borderColor,
    required Color inputBg,
  }) {
    final isChecked = slot.isChecked;
    final isDark = AppColors.current.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFFFEFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isChecked ? _yellowAccent : borderColor,
          width: isChecked ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Yellow Checkbox
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => slot.isChecked = !slot.isChecked);
              widget.onWeeklySlotsChanged(widget.weeklySlots);
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isChecked ? _yellowAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked ? _yellowAccent : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF1A1D20))
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Day Label (Mon, Tue, etc.)
          SizedBox(
            width: 38,
            child: Text(
              slot.dayName,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Start Time Field
          Expanded(
            child: GestureDetector(
              onTap: isChecked ? () => _pickSlotTime(context, index, true) : null,
              child: Container(
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? inputBg : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isChecked ? borderColor : borderColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _formatTime(slot.startTime),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isChecked ? titleColor : titleColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '-',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isChecked ? const Color(0xFF9CA3AF) : const Color(0xFFD1D5DB),
              ),
            ),
          ),

          // End Time Field
          Expanded(
            child: GestureDetector(
              onTap: isChecked ? () => _pickSlotTime(context, index, false) : null,
              child: Container(
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? inputBg : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isChecked ? borderColor : borderColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _formatTime(slot.endTime),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isChecked ? titleColor : titleColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Monthly View (Screenshot 3) ─────────────────────────────────────────────
  Widget _buildMonthlyView(
    BuildContext context, {
    required Color titleColor,
    required Color helperColor,
    required Color borderColor,
    required Color inputBg,
    required Color cardBg,
  }) {
    final minDate = _minSelectableDate;
    final currentMonth = widget.selectedMonth;
    final firstDayOfWeek = DateTime(currentMonth.year, currentMonth.month, 1).weekday; // 1=Mon .. 7=Sun
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final canGoPrev = DateTime(currentMonth.year, currentMonth.month, 1)
        .isAfter(DateTime(minDate.year, minDate.month, 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month navigation row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              color: titleColor,
              onPressed: canGoPrev
                  ? () => widget.onSelectedMonthChanged(
                      DateTime(currentMonth.year, currentMonth.month - 1, 1))
                  : null,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: currentMonth.month,
                    dropdownColor: cardBg,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                    items: [
                      for (int m = 1; m <= 12; m++)
                        if (currentMonth.year > minDate.year || m >= minDate.month)
                          DropdownMenuItem(value: m, child: Text(_monthName(m))),
                    ],
                    onChanged: (m) {
                      if (m != null) {
                        widget.onSelectedMonthChanged(DateTime(currentMonth.year, m, 1));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: currentMonth.year,
                    dropdownColor: cardBg,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                    items: [
                      for (int y = minDate.year; y <= _maxSelectableDate.year; y++)
                        DropdownMenuItem(value: y, child: Text('$y')),
                    ],
                    onChanged: (y) {
                      if (y == null) return;
                      var month = currentMonth.month;
                      if (y == minDate.year && month < minDate.month) {
                        month = minDate.month;
                      }
                      widget.onSelectedMonthChanged(DateTime(y, month, 1));
                    },
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              color: titleColor,
              onPressed: () => widget.onSelectedMonthChanged(
                  DateTime(currentMonth.year, currentMonth.month + 1, 1)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Calendar Month Container
        if (widget.datesError != null)
          Padding(
            key: widget.datesKey,
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.datesError!,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
          ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.datesError != null ? const Color(0xFFD32F2F) : borderColor,
              width: widget.datesError != null ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              // Weekday Headers: M T W T F S S
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _CalendarHeader('M'),
                  _CalendarHeader('T'),
                  _CalendarHeader('W'),
                  _CalendarHeader('T'),
                  _CalendarHeader('F'),
                  _CalendarHeader('S'),
                  _CalendarHeader('S'),
                ],
              ),
              const SizedBox(height: 12),

              // Calendar Days Grid
              _buildCalendarDaysGrid(
                month: currentMonth,
                firstDayOfWeek: firstDayOfWeek,
                daysInMonth: daysInMonth,
                titleColor: titleColor,
                helperColor: helperColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDaysGrid({
    required DateTime month,
    required int firstDayOfWeek,
    required int daysInMonth,
    required Color titleColor,
    required Color helperColor,
  }) {
    final totalCells = ((firstDayOfWeek - 1 + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (ctx, index) {
        final dayNumber = index - (firstDayOfWeek - 1) + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(month.year, month.month, dayNumber);
        final isSelected = widget.selectedMonthlyDates.contains(date);
        final isEnabled = !date.isBefore(_minSelectableDate) && !date.isAfter(_maxSelectableDate);
        final dayStr = dayNumber.toString().padLeft(2, '0');

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: !isEnabled
              ? null
              : () {
                  final next = Set<DateTime>.from(widget.selectedMonthlyDates);
                  if (isSelected) {
                    next.remove(date);
                  } else {
                    next.add(date);
                  }
                  widget.onMonthlyDatesChanged(next);
                },
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF6B6654) : Colors.transparent,
                border: isSelected
                    ? Border.all(color: _yellowAccent, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                dayStr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isEnabled ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final String label;
  const _CalendarHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}
