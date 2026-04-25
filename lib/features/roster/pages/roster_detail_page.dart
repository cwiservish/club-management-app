import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../models/roster_detail_contact.dart';
import '../models/roster_member.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/roster_detail_provider.dart';
import '../widgets/roster_detail_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Roster Detail Page
// ══════════════════════════════════════════════════════════════════════════════

class RosterDetailPage extends ConsumerWidget {
  final String memberId;
  const RosterDetailPage({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final member = ref.watch(rosterDetailProvider(memberId));
    final contacts = buildRosterDetailContacts(member);

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: '',
              leftLabel: 'Roster',
              rightText: 'Edit',
              onRightTap: () => _showEditSheet(context, member),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RosterProfileSection(
                      member: member,
                      onAvatarTap: () => _showEditSheet(context, member),
                    ),
                    const RosterActionButtons(),
                    RosterFamilyContactsSection(
                      contacts: contacts,
                      onContactTap: (c) => _showContactDialog(context, c),
                      onAddFamilyTap: () => _showAddFamilySheet(context),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, RosterMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RosterEditPlayerSheet(member: member),
    );
  }

  void _showContactDialog(BuildContext context, RosterDetailContact contact) {
    showDialog(
      context: context,
      builder: (_) => RosterContactActionDialog(contact: contact),
    );
  }

  void _showAddFamilySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RosterAddFamilySheet(),
    );
  }
}
