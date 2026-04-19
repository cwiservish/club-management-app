import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../../../core/shared_widgets/textfield/app_text_field.dart';

// ─── Edit Event Page ──────────────────────────────────────────────────────────

class EventEditPage extends StatefulWidget {
  final String eventId;

  const EventEditPage({super.key, required this.eventId});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  bool _notifyTeam = true;
  bool _timeTbd = false;
  bool _trackAvail = true;
  bool _canceled = false;

  final _notesController = TextEditingController();
  final _eventNameController = TextEditingController(text: 'Practice');
  final _locationDetailsController = TextEditingController();
  final _extraLabelController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _eventNameController.dispose();
    _locationDetailsController.dispose();
    _extraLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Scaffold(
      backgroundColor: colors.card,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: 'Edit Event',
              leftIcon: Icons.close,
              leftLabel: 'Close',
              onLeftTap: () => Navigator.maybePop(context),
              rightText: 'Save',
              onRightTap: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(19, 20, 19, 40),
                children: [
                  // ── Notify Team ─────────────────────────────────────────────
                  _NotifyCard(
                    value: _notifyTeam,
                    onChanged: (v) => setState(() => _notifyTeam = v),
                  ),
                  const SizedBox(height: 20),

                  // ── Basic Details ───────────────────────────────────────────
                  _FormCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Basic Details',
                    children: [
                      _InlineField(
                        label: 'Event Name',
                        controller: _eventNameController,
                        placeholder: 'e.g. Game, Practice, Tournament',
                        borderBottom: true,
                      ),
                      _ListRow(label: 'Date/Time',  value: '03/25/26  6:00 PM'),
                      _ListRow(label: 'Time Zone',  value: 'Central Time (US & C...)'),
                      _ToggleRow(
                        label: 'Time TBD',
                        value: _timeTbd,
                        onChanged: (v) => setState(() => _timeTbd = v),
                      ),
                      _ListRow(label: 'Duration', value: '1 Hour 30 Minutes', borderBottom: false),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Location ────────────────────────────────────────────────
                  _FormCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    children: [
                      _ListRow(label: 'Location', value: 'Gillis-Rother Soccer C...'),
                      _InlineField(
                        label: 'Location Details',
                        controller: _locationDetailsController,
                        placeholder: 'e.g. Field #5, Turf Field',
                        borderBottom: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Logistics & Settings ────────────────────────────────────
                  _FormCard(
                    icon: Icons.settings_outlined,
                    title: 'Logistics & Settings',
                    children: [
                      _ListRow(label: 'Arrive Early', value: '15 Minutes'),
                      _ToggleRow(
                        label: 'Track Availability',
                        value: _trackAvail,
                        onChanged: (v) => setState(() => _trackAvail = v),
                      ),
                      _ListRow(label: 'Flag Color', value: 'Blackberry'),
                      _InlineField(
                        label: 'Extra Label',
                        controller: _extraLabelController,
                        placeholder: 'Optional secondary label',
                        borderBottom: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Notes ───────────────────────────────────────────────────
                  _FormCard(
                    icon: Icons.align_horizontal_left_outlined,
                    title: 'Notes',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AppTextField(
                          controller: _notesController,
                          hintText: 'Add any additional details or instructions for the team...',
                          minLines: 4,
                          maxLines: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Danger Zone ─────────────────────────────────────────────
                  _DangerCard(
                    canceled: _canceled,
                    onCanceledChanged: (v) => setState(() => _canceled = v),
                    onDelete: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notify Card ──────────────────────────────────────────────────────────────

class _NotifyCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifyCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_outlined, size: 16, color: colors.actionAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notify Team',
                  style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                ),
                Text(
                  'Send push & email notifications',
                  style: AppTextStyles.label12.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          _Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Form Card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _FormCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: colors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

// ─── Inline text field (transparent, no border) ───────────────────────────────

class _InlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool borderBottom;

  const _InlineField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.borderBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: borderBottom
            ? Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label12.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            cursorColor: colors.primary,
            style: AppTextStyles.body16.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.body16.copyWith(color: colors.gray300),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tappable list row ────────────────────────────────────────────────────────

class _ListRow extends StatelessWidget {
  final String label;
  final String value;
  final bool borderBottom;
  final VoidCallback? onTap;

  const _ListRow({
    required this.label,
    required this.value,
    this.borderBottom = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle row ───────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
            ),
          ),
          _Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Danger zone card ─────────────────────────────────────────────────────────

class _DangerCard extends StatelessWidget {
  final bool canceled;
  final ValueChanged<bool> onCanceledChanged;
  final VoidCallback onDelete;

  const _DangerCard({
    required this.canceled,
    required this.onCanceledChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.error.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Cancel Event toggle row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancel Event',
                        style: AppTextStyles.heading15.copyWith(color: colors.error),
                      ),
                      Text(
                        'Mark this event as canceled',
                        style: AppTextStyles.label12.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _Toggle(value: canceled, onChanged: onCanceledChanged, isDanger: true),
              ],
            ),
          ),

          // Delete button
          InkWell(
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 20, color: colors.error),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Event Permanently',
                    style: AppTextStyles.heading15.copyWith(color: colors.error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle switch ────────────────────────────────────────────────────────────

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDanger;

  const _Toggle({
    required this.value,
    required this.onChanged,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final activeColor = isDanger ? colors.error : colors.rsvpGoing;
    final trackColor = value ? activeColor : colors.gray300;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
