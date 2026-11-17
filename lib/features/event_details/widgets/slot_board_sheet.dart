import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/new_event_dropdown_options_model.dart';
import '../models/session_slot_models.dart';
import '../services/event_detail_service.dart';

/// Bottom sheet that shows every date of a type-1 (Our Facilities) session with its
/// availability. The user can change a row's time or field (only that row is re-checked)
/// and saves once nothing is blocking.
///
/// A clashing date can be removed (with Undo) so the rest can still be saved.
/// The date of every editable card can be changed (never to a past date or to another card's date);
/// only that card is re-checked, and the cards are re-sorted by date.
///
/// Pops with the rows to send as `slots` (locked and removed rows left out), or null if cancelled.
class SlotBoardSheet extends StatefulWidget {
  final EventDetailService service;
  final String teamUuid;
  final OurLocationVenue venue;
  final SlotBoard board;
  final String saveLabel;

  /// Confirm board: dates can't be edited here (change them from Edit event).
  final bool readOnly;

  /// false hides the date chips (no caller needs that now: the server accepts a date change on one occurrence).
  final bool dateEditable;

  const SlotBoardSheet({
    super.key,
    required this.service,
    required this.teamUuid,
    required this.venue,
    required this.board,
    this.saveLabel = 'Save',
    this.readOnly = false,
    this.dateEditable = true,
  });

  static Future<List<SessionSlot>?> show(
    BuildContext context, {
    required EventDetailService service,
    required String teamUuid,
    required OurLocationVenue venue,
    required SlotBoard board,
    String saveLabel = 'Save',
    bool readOnly = false,
    bool dateEditable = true,
  }) {
    return showModalBottomSheet<List<SessionSlot>>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => SlotBoardSheet(
        service: service,
        teamUuid: teamUuid,
        venue: venue,
        board: board,
        saveLabel: saveLabel,
        readOnly: readOnly,
        dateEditable: dateEditable,
      ),
    );
  }

  @override
  State<SlotBoardSheet> createState() => _SlotBoardSheetState();
}

/// A card with a stable id: rows are re-sorted when a date changes, so state is keyed by id, not position.
class _Row {
  final int id;
  SessionSlot slot;
  _Row(this.id, this.slot);
}

class _SlotBoardSheetState extends State<SlotBoardSheet> {
  late List<_Row> _rows;
  final Set<int> _checking = {};

  /// Rows the user removed: not saved. Rows are never deleted, so Undo works.
  final Set<int> _removed = {};

  /// Rows whose date/time/field changed and have not been checked yet.
  final Set<int> _stale = {};

  /// Rows the user moved onto a date another card already has (shown with an inline error, not re-checked).
  final Set<int> _dateErr = {};

  /// Latest check per row; a response for an older check is ignored.
  final Map<int, int> _version = {};

  @override
  void initState() {
    super.initState();
    _rows = [for (var i = 0; i < widget.board.slots.length; i++) _Row(i, widget.board.slots[i])];
  }

  _Row? _byId(int id) => _rows.where((r) => r.id == id).firstOrNull;

  Iterable<_Row> get _active => _rows.where((r) => !_removed.contains(r.id));

  /// Another card (locked ones too, removed ones not) already has this row's date.
  bool _sharesDate(_Row r) => _active.any((o) => o.id != r.id && o.slot.date == r.slot.date);
  bool _dupError(_Row r) => _dateErr.contains(r.id) && _sharesDate(r);

  /// Cards that count in the header: every editable card, plus locked ones that are confirm-only.
  Iterable<_Row> get _counted => _active.where((r) => !r.slot.locked || r.slot.confirmOnly);
  int get _headerClashCount => _counted.where((r) => r.slot.isBlocking || _dupError(r)).length;
  int get _blockingCount => _active.where((r) => !r.slot.locked && r.slot.isBlocking).length;

  /// Dates that will be written (not locked, not removed).
  int get _saveCount => _active.where((r) => !r.slot.locked).length;
  bool get _canSave =>
      _blockingCount == 0 &&
      _checking.isEmpty &&
      _stale.isEmpty &&
      !_active.any(_dupError) &&
      _saveCount > 0;

  /// A clashing row can be removed as long as another date is left to save.
  bool _canRemove(_Row r) =>
      !widget.readOnly && !r.slot.locked && (r.slot.isBlocking || _dupError(r)) && !_checking.contains(r.id) && _saveCount > 1;

  // ── helpers ────────────────────────────────────────────────────────────────

  TimeOfDay _parseTime(String hhmm) {
    final p = hhmm.split(':');
    return TimeOfDay(hour: int.tryParse(p[0]) ?? 0, minute: p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
  }

  String _fmt24(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _fmt12(String hhmm) {
    final t = _parseTime(hhmm);
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _fmtDate(String yyyyMmDd) {
    final d = DateTime.tryParse(yyyyMmDd);
    if (d == null) return yyyyMmDd;
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${wd[d.weekday - 1]}, ${mo[d.month - 1]} ${d.day}';
  }

  String _fieldName(int? id) {
    for (final f in widget.venue.fields) {
      if (f.fieldId == id) return f.fieldName.isNotEmpty ? f.fieldName : f.label;
    }
    return id == null ? 'No field' : 'Field $id';
  }

  // ── actions ────────────────────────────────────────────────────────────────

  void _sortRows() => _rows.sort((a, b) {
        final c = a.slot.date.compareTo(b.slot.date);
        return c != 0 ? c : a.id.compareTo(b.id);
      });

  /// Re-checks one card with `field_availability`. A response for a card that was changed again meanwhile is ignored.
  Future<void> _recheck(int id, SessionSlot updated) async {
    final row = _byId(id);
    final fieldId = updated.fieldId;
    if (row == null || fieldId == null) return;
    final version = (_version[id] ?? 0) + 1;
    _version[id] = version;
    setState(() {
      row.slot = updated;
      _checking.add(id);
      _stale.add(id);
    });
    SessionSlot result;
    try {
      result = await widget.service.checkFieldAvailability(
        teamUuid: widget.teamUuid,
        venueId: widget.venue.venueId,
        fieldId: fieldId,
        slot: updated,
        excludeIds: widget.board.excludeIds,
      );
    } catch (e) {
      // Treat a failed check as blocking so the user can't save an unchecked row.
      result = updated.copyWith(
        checked: true,
        isAvailable: false,
        isBlocking: true,
        warnings: [e.toString()],
        message: e.toString(),
      );
    }
    if (!mounted || _version[id] != version) return;
    setState(() {
      row.slot = result;
      _checking.remove(id);
      _stale.remove(id);
    });
  }

  Future<void> _pickTime(int id, {required bool isStart}) async {
    final slot = _byId(id)!.slot;
    final initial = _parseTime(isStart ? slot.startTime : slot.endTime);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    var start = _parseTime(slot.startTime);
    var end = _parseTime(slot.endTime);
    final durationMin = (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    if (isStart) {
      start = picked;
      // keep the same length when the start moves
      final endMin = (start.hour * 60 + start.minute) + (durationMin > 0 ? durationMin : 60);
      end = TimeOfDay(hour: (endMin ~/ 60) % 24, minute: endMin % 60);
    } else {
      end = picked;
    }
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;
    if (endMin <= startMin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after the start time')),
      );
      return;
    }
    if (!mounted) return;
    final row = _byId(id);
    if (row == null) return;
    await _recheck(id, row.slot.copyWith(startTime: _fmt24(start), endTime: _fmt24(end)));
  }

  Future<void> _pickField(int id, int chosen) async {
    final slot = _byId(id)!.slot;
    if (chosen == slot.fieldId) return;
    await _recheck(id, slot.copyWith(fieldId: chosen));
  }

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Changes a card's date. A past date can't be picked. A date another card already has is not
  /// re-checked: the card shows an inline error and stays not ready. Otherwise only this card is
  /// re-checked, and any card left alone on the old date is re-checked too.
  Future<void> _pickDate(int id) async {
    final row = _byId(id);
    if (row == null) return;
    final today = DateUtils.dateOnly(DateTime.now());
    final current = DateTime.tryParse(row.slot.date);
    final initial = current == null || current.isBefore(today) ? today : DateUtils.dateOnly(current);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked == null || !mounted) return;

    final oldDate = row.slot.date;
    final newDate = _ymd(picked);
    if (newDate == oldDate) return;

    final taken = _active.any((o) => o.id != id && o.slot.date == newDate);
    final moved = row.slot.copyWith(date: newDate, checked: false, isBlocking: false, warnings: const [], message: '');
    if (taken) {
      _version[id] = (_version[id] ?? 0) + 1; // drop any check still running for the old date
      setState(() {
        row.slot = moved;
        _checking.remove(id);
        _stale.add(id);
        _dateErr.add(id);
        _sortRows();
      });
    } else {
      setState(() {
        _dateErr.remove(id);
        row.slot = moved;
        _sortRows();
      });
      _recheck(id, moved);
    }

    // Cards left on the old date: they were sharing it, so check them again.
    for (final other in _active.toList()) {
      if (other.id == id || other.slot.locked || other.slot.date != oldDate) continue;
      _dateErr.remove(other.id);
      _recheck(other.id, other.slot);
    }
  }

  /// Field chip with its list anchored to it (opens below, or above when there's no room).
  Widget _fieldMenu(int id, String label, bool disabled) {
    final slot = _byId(id)!.slot;
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        alignmentOffset: const Offset(0, 6),
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(6),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
          minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 0)),
          maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 300)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color(0xFFD1D5DB)),
          )),
        ),
        menuChildren: [
          for (final f in widget.venue.fields)
            MenuItemButton(
              onPressed: () => _pickField(id, f.fieldId),
              trailingIcon: f.fieldId == slot.fieldId ? const Icon(Icons.check, size: 18, color: Color(0xFFF5BD1F)) : null,
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 44)),
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
                backgroundColor: WidgetStatePropertyAll(
                  f.fieldId == slot.fieldId ? const Color(0xFFF5BD1F).withValues(alpha: 0.18) : Colors.transparent,
                ),
              ),
              child: Text(
                f.fieldName.isNotEmpty ? f.fieldName : f.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF1A1D20),
                  fontWeight: f.fieldId == slot.fieldId ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
        ],
        builder: (context, controller, _) => _tapChip(
          label,
          Icons.place_outlined,
          () => controller.isOpen ? controller.close() : controller.open(),
          disabled,
          expand: true,
        ),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    final bg = isDark ? colors.card : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1D20);
    final subColor = isDark ? colors.textSecondary : const Color(0xFF6B7280);
    final height = MediaQuery.of(context).size.height * 0.88;
    final clashes = _headerClashCount;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, clashes == 0 ? 12 : 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Check availability',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: titleColor),
                ),
              ),
            ),
            if (clashes > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$clashes of ${_counted.length} dates clash at ${widget.venue.name}. '
                    '${widget.readOnly ? 'Edit the event to change them before confirming.' : 'Change the date, time, or field for the red dates.'}',
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFFD32F2F), height: 1.35),
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildRow(_rows[i], titleColor, subColor, isDark),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Back', style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canSave
                          ? () => Navigator.pop(context, [
                                for (final r in _active)
                                  if (!r.slot.locked) r.slot,
                              ])
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: const Color(0xFFF5BD1F),
                        foregroundColor: const Color(0xFF1A1D20),
                        disabledBackgroundColor: const Color(0xFFE5E7EB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(widget.saveLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(_Row row, Color titleColor, Color subColor, bool isDark) {
    if (_removed.contains(row.id)) return _buildRemovedRow(row, titleColor, subColor, isDark);
    final s = row.slot;
    final checking = _checking.contains(row.id);
    final dup = _dupError(row);
    final clash = !s.locked && (s.isBlocking || dup);
    final border = s.locked
        ? const Color(0xFFD1D5DB)
        : clash
            ? const Color(0xFFD32F2F)
            : const Color(0xFFE5E7EB);
    final fieldLabel = _fieldName(s.fieldId);
    final canEditDate = widget.dateEditable && !widget.readOnly && !s.locked;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: s.locked
            ? (isDark ? Colors.white10 : const Color(0xFFF4F5F7))
            : clash
                ? const Color(0xFFFDECEA)
                : (isDark ? Colors.transparent : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: clash ? 1.4 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: canEditDate
                      ? _tapChip(_fmtDate(s.date), Icons.calendar_today_outlined, () => _pickDate(row.id), checking)
                      : Text(
                          _fmtDate(s.date),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: clash ? const Color(0xFF1A1D20) : titleColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(row, checking, dup),
            ],
          ),
          const SizedBox(height: 8),
          if (s.locked)
            Text(
              s.lockedLabel.isNotEmpty ? s.lockedLabel : 'Edited separately — will not change',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: subColor),
            )
          else ...[
            Row(
              children: [
                _tapChip(_fmt12(s.startTime), Icons.access_time, () => _pickTime(row.id, isStart: true), checking || widget.readOnly),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('–')),
                _tapChip(_fmt12(s.endTime), null, () => _pickTime(row.id, isStart: false), checking || widget.readOnly),
              ],
            ),
            const SizedBox(height: 8),
            _fieldMenu(row.id, widget.readOnly && widget.venue.fields.isEmpty ? widget.venue.name : fieldLabel, checking || widget.readOnly),
          ],
          if (dup) ...[
            const SizedBox(height: 8),
            const Text(
              'This date is already in your schedule. Pick a different date.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFFB71C1C), height: 1.3),
            ),
          ] else if (clash && s.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final w in s.warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(w, style: const TextStyle(fontSize: 12.5, color: Color(0xFFB71C1C), height: 1.3)),
              ),
          ],
          if (_canRemove(row)) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _removed.add(row.id)),
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFD32F2F)),
                label: const Text(
                  'Remove this date',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// A removed date: greyed out, won't be saved, with Undo.
  Widget _buildRemovedRow(_Row row, Color titleColor, Color subColor, bool isDark) {
    final s = row.slot;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fmtDate(s.date),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: subColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Removed — this date will not be saved', style: TextStyle(fontSize: 12.5, color: subColor)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _removed.remove(row.id)),
            child: const Text('Undo', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(_Row row, bool checking, bool dup) {
    final s = row.slot;
    if (checking) {
      return const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2));
    }
    String text;
    Color color;
    if (s.locked) {
      text = 'Locked';
      color = const Color(0xFF6B7280);
    } else if (dup) {
      text = 'Not ready';
      color = const Color(0xFFD32F2F);
    } else if (s.isBlocking) {
      text = 'Clash';
      color = const Color(0xFFD32F2F);
    } else {
      text = 'Available';
      color = const Color(0xFF2E7D32);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _tapChip(String text, IconData? icon, VoidCallback onTap, bool disabled, {bool expand = false}) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16, color: const Color(0xFF6B7280)), const SizedBox(width: 6)],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1A1D20)),
            ),
          ),
          if (expand) const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
    return GestureDetector(onTap: disabled ? null : onTap, child: child);
  }
}
