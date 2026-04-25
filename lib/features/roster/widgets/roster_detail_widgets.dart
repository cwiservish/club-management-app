import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/member_role.dart';
import '../models/roster_member.dart';
import '../models/roster_detail_contact.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Profile Section
// ══════════════════════════════════════════════════════════════════════════════

class RosterProfileSection extends StatelessWidget {
  final RosterMember member;
  final VoidCallback onAvatarTap;

  const RosterProfileSection({
    super.key,
    required this.member,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.current.surface,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.current.primaryLight,
                border: Border.all(color: AppColors.current.surface, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                member.initials,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.current.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.current.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (member.role == MemberRole.player && member.jerseyNumber != null) ...[
                      RosterJerseyBadge(number: member.jerseyNumber!),
                      const SizedBox(width: 8),
                    ],
                    if (member.positionFull.isNotEmpty || member.staffTitle != null)
                      Text(
                        member.role == MemberRole.player
                            ? member.positionFull
                            : (member.staffTitle ?? ''),
                        style: AppTextStyles.body14.copyWith(
                          color: AppColors.current.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RosterJerseyBadge extends StatelessWidget {
  final int number;
  const RosterJerseyBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.current.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.current.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '#$number',
        style: AppTextStyles.heading14.copyWith(color: AppColors.current.primary),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Action Buttons
// ══════════════════════════════════════════════════════════════════════════════

class RosterActionButtons extends StatelessWidget {
  final VoidCallback? onStatisticsTap;
  final VoidCallback? onAttendanceTap;
  const RosterActionButtons({super.key, this.onStatisticsTap, this.onAttendanceTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: RosterNavButton(label: 'Statistics', onTap: onStatisticsTap)),
          const SizedBox(width: 12),
          Expanded(child: RosterNavButton(label: 'Attendance', onTap: onAttendanceTap)),
        ],
      ),
    );
  }
}

class RosterNavButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const RosterNavButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.current.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.heading14.copyWith(color: AppColors.current.textPrimary),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppColors.current.gray400),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Family & Contacts Section
// ══════════════════════════════════════════════════════════════════════════════

class RosterFamilyContactsSection extends StatelessWidget {
  final List<RosterDetailContact> contacts;
  final ValueChanged<RosterDetailContact> onContactTap;
  final VoidCallback onAddFamilyTap;

  const RosterFamilyContactsSection({
    super.key,
    required this.contacts,
    required this.onContactTap,
    required this.onAddFamilyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group_outlined, size: 22, color: AppColors.current.textPrimary),
              const SizedBox(width: 8),
              Text(
                'Family & Contacts',
                style: AppTextStyles.heading16.copyWith(
                  color: AppColors.current.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.current.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.current.border.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ...contacts.map((c) => RosterContactRow(
                      contact: c,
                      isLast: contacts.last == c,
                      onTap: () => onContactTap(c),
                    )),
                RosterAddFamilyButton(onTap: onAddFamilyTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RosterContactRow extends StatelessWidget {
  final RosterDetailContact contact;
  final bool isLast;
  final VoidCallback onTap;

  const RosterContactRow({
    super.key,
    required this.contact,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: AppColors.current.border.withOpacity(0.4))),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.current.primaryLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                contact.initials,
                style: AppTextStyles.heading14.copyWith(
                  color: AppColors.current.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact.name,
                        style: AppTextStyles.body15.copyWith(
                          color: AppColors.current.textPrimary,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RosterRelationBadge(label: contact.relation),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        contact.isEmail ? Icons.mail_outline : Icons.phone_outlined,
                        size: 14,
                        color: AppColors.current.gray400,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          contact.value,
                          style: AppTextStyles.body13.copyWith(color: AppColors.current.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppColors.current.gray300),
          ],
        ),
      ),
    );
  }
}

class RosterRelationBadge extends StatelessWidget {
  final String label;
  const RosterRelationBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label11.copyWith(
          color: AppColors.current.gray500,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class RosterAddFamilyButton extends StatelessWidget {
  final VoidCallback onTap;
  const RosterAddFamilyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: AppColors.current.card,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.current.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            'Add Family Member',
            style: AppTextStyles.heading14.copyWith(
              color: AppColors.current.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Contact Action Dialog
// ══════════════════════════════════════════════════════════════════════════════

class RosterContactActionDialog extends StatelessWidget {
  final RosterDetailContact contact;
  const RosterContactActionDialog({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.current.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Contact ${contact.name}',
                    style: AppTextStyles.heading16.copyWith(color: AppColors.current.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.current.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18, color: AppColors.current.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RosterDialogOption(
              icon: Icons.mail_outline,
              label: 'Send Email',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            RosterDialogOption(
              icon: Icons.sms_outlined,
              label: 'Send SMS Message',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            RosterDialogOption(
              icon: Icons.chat_bubble_outline,
              label: 'Direct Message In-App',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class RosterDialogOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const RosterDialogOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.current.border.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.current.gray400),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.body15.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Edit Player Sheet
// ══════════════════════════════════════════════════════════════════════════════

class RosterEditPlayerSheet extends StatefulWidget {
  final RosterMember member;
  const RosterEditPlayerSheet({super.key, required this.member});

  @override
  State<RosterEditPlayerSheet> createState() => _RosterEditPlayerSheetState();
}

class _RosterEditPlayerSheetState extends State<RosterEditPlayerSheet> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _jerseyCtrl;
  late String _position;

  static const _positions = ['Forward', 'Midfielder', 'Defender', 'Goalkeeper'];

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.member.firstName);
    _lastNameCtrl  = TextEditingController(text: widget.member.lastName);
    _jerseyCtrl    = TextEditingController(text: widget.member.jerseyNumber?.toString() ?? '');
    _position = widget.member.positionFull.isNotEmpty
        ? widget.member.positionFull
        : _positions.first;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _jerseyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RosterSheetHandle(),
          RosterSheetHeader(
            title: 'Edit Player',
            onCancel: () => Navigator.pop(context),
            onSave: () => Navigator.pop(context),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 40),
            child: Column(
              children: [
                // Avatar preview
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.current.primaryLight,
                    border: Border.all(color: AppColors.current.surface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.member.initials,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.current.primary,
                    ),
                  ),
                ),
                RosterFormCard(
                  children: [
                    RosterFormField(label: 'First Name', controller: _firstNameCtrl),
                    const RosterFieldDivider(),
                    RosterFormField(label: 'Last Name', controller: _lastNameCtrl),
                    const RosterFieldDivider(),
                    if (widget.member.role == MemberRole.player) ...[
                      RosterFormField(
                        label: 'Jersey Number',
                        controller: _jerseyCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      const RosterFieldDivider(),
                      RosterDropdownField(
                        label: 'Position',
                        value: _positions.contains(_position) ? _position : _positions.first,
                        options: _positions,
                        onChanged: (v) => setState(() => _position = v!),
                      ),
                    ] else if (widget.member.staffTitle != null) ...[
                      RosterFormField(
                        label: 'Title',
                        controller: TextEditingController(text: widget.member.staffTitle),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Add Family Sheet
// ══════════════════════════════════════════════════════════════════════════════

class RosterAddFamilySheet extends StatefulWidget {
  const RosterAddFamilySheet({super.key});

  @override
  State<RosterAddFamilySheet> createState() => _RosterAddFamilySheetState();
}

class _RosterAddFamilySheetState extends State<RosterAddFamilySheet> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RosterSheetHandle(),
          RosterSheetHeader(
            title: 'New Family Member',
            onCancel: () => Navigator.pop(context),
            onSave: () => Navigator.pop(context),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 40),
            child: RosterFormCard(
              children: [
                RosterFormField(label: 'First Name', controller: _firstNameCtrl, hint: 'e.g. Jane'),
                const RosterFieldDivider(),
                RosterFormField(label: 'Last Name', controller: _lastNameCtrl, hint: 'e.g. Doe'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared sheet primitives
// ══════════════════════════════════════════════════════════════════════════════

class RosterSheetHandle extends StatelessWidget {
  const RosterSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.current.border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class RosterSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const RosterSheetHeader({
    super.key,
    required this.title,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        border: Border(bottom: BorderSide(color: AppColors.current.border.withOpacity(0.5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.heading16.copyWith(color: AppColors.current.textPrimary),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onCancel,
              child: Text(
                'Cancel',
                style: AppTextStyles.body15.copyWith(
                  color: AppColors.current.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onSave,
              child: Text(
                'Save',
                style: AppTextStyles.heading14.copyWith(color: AppColors.current.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RosterFormCard extends StatelessWidget {
  final List<Widget> children;
  const RosterFormCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.current.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class RosterFieldDivider extends StatelessWidget {
  const RosterFieldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.current.border.withOpacity(0.4),
    );
  }
}

class RosterFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;

  const RosterFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: AppColors.current.gray500, fontSize: 11),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.body16.copyWith(
              color: AppColors.current.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: AppTextStyles.body16.copyWith(color: AppColors.current.gray400),
            ),
          ),
        ],
      ),
    );
  }
}

class RosterDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const RosterDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: AppColors.current.gray500, fontSize: 11),
          ),
          const SizedBox(height: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isDense: true,
              isExpanded: true,
              style: AppTextStyles.body16.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: AppColors.current.surface,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.current.gray400, size: 20),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
