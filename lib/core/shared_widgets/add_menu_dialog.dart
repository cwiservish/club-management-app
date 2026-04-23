import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

void showAddMenu(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent, // As per figma, popover doesn't darken
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      final topPadding = MediaQuery.of(context).padding.top;
      final colors = AppColors.current;
      
      return Stack(
        children: [
          Positioned(
            top: 53 + topPadding + 8, // Just below the header
            right: 16,
            width: 295,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.7), // bg-white/70
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuOption(
                          icon: '+',
                          label: 'Team',
                          onTap: () {
                            Navigator.of(context).pop();
                            _showNewTeamModal(context);
                          },
                        ),
                        _MenuOption(
                          icon: '+',
                          label: 'Event',
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push(AppRoutes.eventEdit('new'));
                          },
                        ),
                        _MenuOption(
                          icon: '+',
                          label: 'Player',
                          onTap: () {
                            Navigator.of(context).pop();
                            _showNewPlayerModal(context);
                          },
                        ),
                        _MenuOption(
                          icon: '+',
                          label: 'Chat',
                          onTap: () {
                            Navigator.of(context).pop();
                            _showNewChatModal(context);
                          },
                        ),
                        _MenuOption(
                          icon: '+',
                          label: 'Invoice',
                          borderBottom: false,
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push(AppRoutes.invoiceNew);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: child,
      );
    },
  );
}

class _MenuOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool borderBottom;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.borderBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: AppColors.current.border))
              : null,
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.current.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body16.copyWith(
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

// ─── Modal Implementations ──────────────────────────────────────────────────

void _showNewTeamModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NewTeamModal(),
  );
}

class _NewTeamModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Cancel', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('New Team', style: AppTextStyles.heading16.copyWith(color: colors.textPrimary)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Save', style: AppTextStyles.body15.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('TEAM NAME', 'e.g. 12 Girls ECNL RL'),
                      Divider(height: 1, color: colors.border),
                      _buildTextField('DIVISION', 'e.g. U12'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label11.copyWith(color: AppColors.current.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          TextField(
            style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.body16.copyWith(color: AppColors.current.textSecondary.withValues(alpha: 0.5)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

void _showNewPlayerModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NewPlayerModal(),
  );
}

class _NewPlayerModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Cancel', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('New Player', style: AppTextStyles.heading16.copyWith(color: colors.textPrimary)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Save', style: AppTextStyles.body15.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: colors.border,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                      ],
                    ),
                    child: Icon(Icons.camera_alt, color: colors.textSecondary, size: 32),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('FIRST NAME', 'e.g. Preston'),
                      Divider(height: 1, color: colors.border),
                      _buildTextField('LAST NAME', 'e.g. Cole'),
                      Divider(height: 1, color: colors.border),
                      _buildTextField('JERSEY NUMBER', 'e.g. 8'),
                      Divider(height: 1, color: colors.border),
                      _buildTextField('POSITION', 'Select position...'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label11.copyWith(color: AppColors.current.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          TextField(
            style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.body16.copyWith(color: AppColors.current.textSecondary.withValues(alpha: 0.5)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

void _showNewChatModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NewChatModal(),
  );
}

class _NewChatModal extends StatefulWidget {
  @override
  _NewChatModalState createState() => _NewChatModalState();
}

class _NewChatModalState extends State<_NewChatModal> {
  String type = 'select';

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      if (type != 'select') {
                        setState(() => type = 'select');
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Cancel', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    type == 'select' ? 'New Chat' : (type == 'channel' ? 'New Channel' : 'New Direct Message'),
                    style: AppTextStyles.heading16.copyWith(color: colors.textPrimary),
                  ),
                ),
                if (type != 'select') Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/messages/1');
                    },
                    child: Text('Create', style: AppTextStyles.body15.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (type == 'select') Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('New Channel', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
                        onTap: () => setState(() => type = 'channel'),
                      ),
                      Divider(height: 1, color: colors.border),
                      ListTile(
                        title: Text('New Direct Message', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
                        onTap: () => setState(() => type = 'dm'),
                      ),
                    ],
                  ),
                ),
                if (type == 'channel') Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHANNEL NAME', style: AppTextStyles.label11.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'e.g. general',
                            prefixIcon: Icon(Icons.tag, size: 18, color: colors.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Channels are a great way to communicate with everyone on your team.', style: AppTextStyles.label12.copyWith(color: colors.textSecondary)),
                    ],
                  ),
                ),
                if (type == 'dm') Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELECT USER', style: AppTextStyles.label11.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Select a team member...', style: AppTextStyles.body15.copyWith(color: colors.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
