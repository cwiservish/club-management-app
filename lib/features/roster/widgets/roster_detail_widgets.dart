import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/enums/member_role.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../models/roster_member.dart';
import '../models/roster_detail_contact.dart';
import '../models/player_profile_models.dart';
import '../providers/player_profile_provider.dart';
import '../../messages/pages/talkjs_chat_page.dart';
import '../../messages/providers/chat_state_provider.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Profile Section
// ══════════════════════════════════════════════════════════════════════════════

String _formatPosition(String? pos) {
  if (pos == null) return '';
  final p = pos.toLowerCase().trim();
  if (p.isEmpty) return '';

  if (p == '1' || p == 'goalkeeper' || p == 'gk') return 'Goalkeeper';
  if (p == '2' || p == 'defender' || p == 'def') return 'Defender';
  if (p == '3' || p == 'midfielder' || p == 'mid') return 'Midfielder';
  if (p == '4' || p == 'forward' || p == 'fwd') return 'Forward';

  return p[0].toUpperCase() + p.substring(1);
}

class RosterProfileSection extends StatelessWidget {
  final RosterMember member;
  final VoidCallback onAvatarTap;
  final String? imageUrl;
  final String? jerseyNo;
  final String? position;

  const RosterProfileSection({
    super.key,
    required this.member,
    required this.onAvatarTap,
    this.imageUrl,
    this.jerseyNo,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    final String apiJersey = (jerseyNo ?? '').trim().toUpperCase();
    final String displayJersey = (apiJersey.isNotEmpty && apiJersey != 'N/A')
        ? jerseyNo!
        : (member.jerseyNumber?.toString() ?? '');

    final String apiPosition = (position ?? '').trim();
    final String formattedPosition = _formatPosition(apiPosition);
    final String displayPosition = formattedPosition.isNotEmpty
        ? formattedPosition
        : member.positionFull;

    final isJerseyValid = displayJersey.trim().isNotEmpty && displayJersey.trim().toUpperCase() != 'N/A';

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
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        imageUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildInitials(),
                      ),
                    )
                  : _buildInitials(),
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
                    if (member.role == MemberRole.player && isJerseyValid) ...[
                      RosterJerseyBadge(jerseyNo: displayJersey),
                      const SizedBox(width: 8),
                    ],
                    if (displayPosition.isNotEmpty || member.staffTitle != null)
                      Text(
                        member.role == MemberRole.player
                            ? displayPosition
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

  Widget _buildInitials() {
    return Text(
      member.initials,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.current.primary,
      ),
    );
  }
}

class RosterJerseyBadge extends StatelessWidget {
  final String jerseyNo;
  const RosterJerseyBadge({super.key, required this.jerseyNo});

  @override
  Widget build(BuildContext context) {
    final clean = jerseyNo.trim().toUpperCase();
    if (clean.isEmpty || clean == 'N/A') return const SizedBox.shrink();

    final label = clean.startsWith('#') ? clean : '#$clean';
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
        label,
        style: AppTextStyles.heading14.copyWith(color: AppColors.current.primary),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Action Buttons
// ══════════════════════════════════════════════════════════════════════════════

class RosterActionButtons extends StatelessWidget {
  final VoidCallback? onAttendanceTap;
  const RosterActionButtons({super.key, this.onAttendanceTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
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
  final bool isLoading;

  const RosterFamilyContactsSection({
    super.key,
    required this.contacts,
    required this.onContactTap,
    required this.onAddFamilyTap,
    this.isLoading = false,
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
                if (contacts.isEmpty && !isLoading)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'No member available',
                      style: AppTextStyles.body14.copyWith(
                        color: AppColors.current.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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
                  if (contact.email.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.mail_outline,
                          size: 14,
                          color: AppColors.current.gray400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            contact.email,
                            style: AppTextStyles.body13.copyWith(color: AppColors.current.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (contact.phone.isNotEmpty) ...[
                    if (contact.email.isNotEmpty) const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.current.gray400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            contact.phone,
                            style: AppTextStyles.body13.copyWith(color: AppColors.current.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
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

class RosterContactActionDialog extends ConsumerWidget {
  final RosterDetailContact contact;
  const RosterContactActionDialog({super.key, required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onTap: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);

                if (contact.email.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('No email address provided for this contact.')),
                  );
                  return;
                }

                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: contact.email,
                );
                try {
                  await launchUrl(emailLaunchUri);
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Could not open email client: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            RosterDialogOption(
              icon: Icons.sms_outlined,
              label: 'Send SMS Message',
              onTap: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);

                if (contact.phone.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('No phone number provided for this contact.')),
                  );
                  return;
                }

                final Uri smsLaunchUri = Uri(
                  scheme: 'sms',
                  path: contact.phone,
                );
                try {
                  await launchUrl(smsLaunchUri);
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Could not open messaging client: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            RosterDialogOption(
              icon: Icons.chat_bubble_outline,
              label: 'Direct Message In-App',
              onTap: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final goRouter = GoRouter.of(context);
                Navigator.pop(context);

                if (contact.email.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('No email address provided for this contact. TalkJS requires an email.')),
                  );
                  return;
                }

                await goRouter.push(
                  '${AppRoutes.messages}/${AppRoutes.messagesChatDetail}',
                  extra: TalkJSChatArgs(
                    conversationId: contact.email,
                    topic: contact.name,
                    isGroup: false,
                    otherUserId: contact.email,
                    otherUserName: contact.name,
                    otherUserEmail: contact.email,
                  ),
                );

                final activeTeam = ref.read(selectedTeamProvider);
                if (activeTeam != null) {
                  ref.invalidate(chatChannelsProvider(activeTeam.uuid));
                  ref.invalidate(chatMembersProvider(activeTeam.uuid));
                }
              },
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
  final PlayerModel? playerProfile;
  final bool isEditable;
  const RosterEditPlayerSheet({
    super.key,
    required this.member,
    this.playerProfile,
    required this.isEditable,
  });

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
    final profile = widget.playerProfile;
    _firstNameCtrl = TextEditingController(
      text: profile != null ? profile.firstName : widget.member.firstName,
    );
    _lastNameCtrl  = TextEditingController(
      text: profile != null ? profile.lastName : widget.member.lastName,
    );
    _jerseyCtrl    = TextEditingController(
      text: profile != null 
          ? profile.jerseyNo 
          : (widget.member.jerseyNumber?.toString() ?? ''),
    );
    _position = (profile != null && profile.primaryPosition.isNotEmpty)
        ? _formatPosition(profile.primaryPosition)
        : (widget.member.positionFull.isNotEmpty ? widget.member.positionFull : _positions.first);
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
            isSaveEnabled: widget.isEditable,
          ),
          Flexible(
            child: SingleChildScrollView(
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
                      RosterFormField(
                        label: 'First Name',
                        controller: _firstNameCtrl,
                        enabled: widget.isEditable,
                      ),
                      const RosterFieldDivider(),
                      RosterFormField(
                        label: 'Last Name',
                        controller: _lastNameCtrl,
                        enabled: widget.isEditable,
                      ),
                      const RosterFieldDivider(),
                      if (widget.member.role == MemberRole.player) ...[
                        RosterFormField(
                          label: 'Jersey Number',
                          controller: _jerseyCtrl,
                          keyboardType: TextInputType.number,
                          enabled: widget.isEditable,
                        ),
                        const RosterFieldDivider(),
                        RosterDropdownField(
                          label: 'Position',
                          value: _positions.contains(_position) ? _position : _positions.first,
                          options: _positions,
                          onChanged: (v) => setState(() => _position = v!),
                          enabled: widget.isEditable,
                        ),
                      ] else if (widget.member.staffTitle != null) ...[
                        RosterFormField(
                          label: 'Title',
                          controller: TextEditingController(text: widget.member.staffTitle),
                          enabled: widget.isEditable,
                        ),
                      ],
                    ],
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

// ══════════════════════════════════════════════════════════════════════════════
// Add Family Sheet
// ══════════════════════════════════════════════════════════════════════════════

class RosterAddFamilySheet extends ConsumerStatefulWidget {
  final String memberId;
  const RosterAddFamilySheet({super.key, required this.memberId});

  @override
  ConsumerState<RosterAddFamilySheet> createState() => _RosterAddFamilySheetState();
}

class _RosterAddFamilySheetState extends ConsumerState<RosterAddFamilySheet> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Please enter an email address', isError: true);
      return;
    }

    // Simple email format validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(playerProfileProvider(widget.memberId).notifier).assignParent(email);
      
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response.success) {
        _showSnackBar(response.message, isError: false);
        Navigator.pop(context); // Close sheet on success
      } else {
        // Show message from API response (already assigned or failed)
        _showSnackBar(response.message, isError: !response.success);
        
        // If it is already assigned, the parent is still updated and returned in data, so we can close the sheet!
        if (response.message.toLowerCase().contains('already assigned')) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? AppColors.current.error : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
            onSave: _isLoading ? () {} : _onSave,
          ),
          if (_isLoading)
            LinearProgressIndicator(
              color: AppColors.current.primary,
              backgroundColor: AppColors.current.primaryLight,
              minHeight: 3,
            ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RosterFormCard(
                    children: [
                      RosterFormField(
                        label: 'Email Address',
                        controller: _emailCtrl,
                        hint: 'e.g. parent@yopmail.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.current.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _onSave,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Send Invitation',
                              style: AppTextStyles.heading14.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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
  final bool isSaveEnabled;

  const RosterSheetHeader({
    super.key,
    required this.title,
    required this.onCancel,
    required this.onSave,
    this.isSaveEnabled = true,
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
              onTap: isSaveEnabled ? onSave : null,
              child: Text(
                'Save',
                style: AppTextStyles.heading14.copyWith(
                  color: isSaveEnabled
                      ? AppColors.current.primary
                      : AppColors.current.gray400,
                ),
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
  final bool enabled;

  const RosterFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.enabled = true,
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
            enabled: enabled,
            style: AppTextStyles.body16.copyWith(
              color: enabled ? AppColors.current.textPrimary : AppColors.current.textSecondary,
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
  final bool enabled;

  const RosterDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
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
                color: enabled ? AppColors.current.textPrimary : AppColors.current.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: AppColors.current.surface,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.current.gray400, size: 20),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}
