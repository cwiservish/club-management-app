import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/new_event_dropdown_options_model.dart';
import '../models/session_slot_models.dart';
import '../services/event_detail_service.dart';

/// Bottom sheet that shows every date of a type-1 (Our Facilities) session with its
/// availability. The user can change a row's time or field (only that row is re-checked)
/// and saves once nothing is blocking.
///
/// Pops with the rows to send as `slots` (locked rows removed), or null if cancelled.
class SlotBoardSheet extends StatefulWidget {
  final EventDetailService service;
  final String teamUuid;
  final OurLocationVenue venue;
  final SlotBoard board;
  final String saveLabel;

  /// Confirm board: dates can't be edited here (change them from Edit event).
  final bool readOnly;

  const SlotBoardSheet({
    super.key,
    required this.service,
    required this.teamUuid,
    required this.venue,
    required this.board,
    this.saveLabel = 'Save',
    this.readOnly = false,
  });

  static Future<List<SessionSlot>?> show(
    BuildContext context, {
    required EventDetailService service,
    required String teamUuid,
    required OurLocationVenue venue,
    required SlotBoard board,
    String saveLabel = 'Save',
    bool readOnly = false,
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
      ),
    );
  }

  @override
  State<SlotBoardSheet> createState() => _SlotBoardSheetState();
}

class _SlotBoardSheetState extends State<SlotBoardSheet> {
  late List<SessionSlot> _slots;
  final Set<int> _checking = {};

  @override
  void initState() {
    super.initState();
    _slots = List.of(widget.board.slots);
  }

  int get _blockingCount => _slots.where((s) => !s.locked && s.isBlocking).length;
  bool get _canSave => _blockingCount == 0 && _checking.isEmpty;

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

  Future<void> _recheck(int index, SessionSlot updated) async {
    final fieldId = updated.fieldId;
    if (fieldId == null) return;
    setState(() {
      _slots[index] = updated;
      _checking.add(index);
    });
    try {
      final result = await widget.service.checkFieldAvailability(
        teamUuid: widget.teamUuid,
        venueId: widget.venue.venueId,
        fieldId: fieldId,
        slot: updated,
        excludeIds: widget.board.excludeIds,
      );
      if (!mounted) return;
      setState(() => _slots[index] = result);
    } catch (e) {
      if (!mounted) return;
      // Treat a failed check as blocking so the user can't save an unchecked row.
      setState(() {
        _slots[index] = updated.copyWith(
          checked: true,
          isAvailable: false,
          isBlocking: true,
          warnings: [e.toString()],
          message: e.toString(),
        );
      });
    } finally {
      if (mounted) setState(() => _checking.remove(index));
    }
  }

  Future<void> _pickTime(int index, {required bool isStart}) async {
    final slot = _slots[index];
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
    await _recheck(index, slot.copyWith(startTime: _fmt24(start), endTime: _fmt24(end)));
  }

  Future<void> _pickField(int index, int chosen) async {
    final slot = _slots[index];
    if (chosen == slot.fieldId) return;
    await _recheck(index, slot.copyWith(fieldId: chosen));
  }

  /// Field chip with its list anchored to it (opens below, or above when there's no room).
  Widget _fieldMenu(int i, String label, bool disabled) {
    final slot = _slots[i];
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
              onPressed: () => _pickField(i, f.fieldId),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Check availability',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: titleColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _blockingCount == 0
                      ? '${_slots.length} date${_slots.length == 1 ? '' : 's'} at ${widget.venue.name} — all available'
                      : '$_blockingCount of ${_slots.length} dates clash at ${widget.venue.name}. ' +
                          (widget.readOnly
                          ? 'These dates clash. Edit the event to change them before confirming.'
                              : 'Change the time or field for the red dates.'),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _blockingCount == 0 ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                    height: 1.35,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                itemCount: _slots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildRow(i, titleColor, subColor, isDark),
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
                          ? () => Navigator.pop(context, _slots.where((s) => !s.locked).toList())
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

  Widget _buildRow(int i, Color titleColor, Color subColor, bool isDark) {
    final s = _slots[i];
    final checking = _checking.contains(i);
    final clash = !s.locked && s.isBlocking;
    final border = s.locked
        ? const Color(0xFFD1D5DB)
        : clash
            ? const Color(0xFFD32F2F)
            : const Color(0xFFE5E7EB);
    final fieldLabel = _fieldName(s.fieldId);

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
                child: Text(
                  _fmtDate(s.date),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: clash ? const Color(0xFF1A1D20) : titleColor),
                ),
              ),
              _statusChip(s, checking),
            ],
          ),
          const SizedBox(height: 8),
          if (s.locked)
            Text(
              s.lockedLabel.isNotEmpty ? s.lockedLabel : 'Edited separately — will not change',
              style: TextStyle(fontSize: 13, color: subColor),
            )
          else ...[
            Row(
              children: [
                _tapChip(_fmt12(s.startTime), Icons.access_time, () => _pickTime(i, isStart: true), checking || widget.readOnly),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('–')),
                _tapChip(_fmt12(s.endTime), null, () => _pickTime(i, isStart: false), checking || widget.readOnly),
              ],
            ),
            const SizedBox(height: 8),
            _fieldMenu(i, widget.readOnly && widget.venue.fields.isEmpty ? widget.venue.name : fieldLabel, checking || widget.readOnly),
          ],
          if (clash && s.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final w in s.warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(w, style: const TextStyle(fontSize: 12.5, color: Color(0xFFB71C1C), height: 1.3)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(SessionSlot s, bool checking) {
    if (checking) {
      return const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2));
    }
    String text;
    Color color;
    if (s.locked) {
      text = 'Locked';
      color = const Color(0xFF6B7280);
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
