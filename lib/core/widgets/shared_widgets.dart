import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_theme.dart';
import '../models/roster_member.dart';

/// Playbook365 — Shared Reusable Widgets

// ─── App Bottom Navigation Bar ────────────────────────────────────────────────

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int messagesBadgeCount;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.messagesBadgeCount = 0,
  });

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.calendar_month_rounded, 'Schedule'),
    (Icons.person_rounded, 'Roster'),
    (Icons.forum_rounded, 'Messages'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final activeColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final inactiveColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final activeBg = isDark ? AppColors.darkCard : const Color(0xFFF0F0F0);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final isActive = i == currentIndex;
          final item = _items[i];
          final color = isActive ? activeColor : inactiveColor;
          final background = isActive ? activeBg : bgColor;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                height: 93,
                color: background,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(item.$1, color: color, size: 28),
                        if (i == 3 && messagesBadgeCount > 0)
                          Positioned(
                            top: -5,
                            right: -8,
                            child: _Badge(count: messagesBadgeCount),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ─── App Header ───────────────────────────────────────────────────────────────

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showSubHeader;
  final String subHeaderTitle;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    this.showSubHeader = true,
    this.subHeaderTitle = 'Home',
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final dropdownBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Header
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 8),
          color: bgColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: textColor, size: 28),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: dropdownBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '12 Girls ECNL RL',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, color: textColor.withOpacity(0.7), size: 18),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(Icons.add_box_rounded, color: textColor, size: 24),
              ],
            ),
          ),
        ),
        // Sub Header
        if (showSubHeader)
          Container(
            height: 44,
            color: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color: textColor.withOpacity(0.5), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        subHeaderTitle,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        Divider(height: 1, thickness: 0.5, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(showSubHeader ? 104 : 60);
}

// ─── Section Header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final int? count;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.headlineSmall),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: AppRadius.pillRadius,
            ),
            child: Text('$count',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.gray500)),
          ),
        ],
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.smRadius,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.displayMedium.copyWith(fontSize: 22)),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

// ─── Member Avatar ────────────────────────────────────────────────────────────

class MemberAvatar extends StatelessWidget {
  final RosterMember member;
  final double radius;
  final bool showJerseyBadge;
  final bool showOnlineIndicator;
  final bool isOnline;

  const MemberAvatar({
    super.key,
    required this.member,
    this.radius = 22,
    this.showJerseyBadge = true,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: member.avatarColor.withOpacity(0.15),
          child: Text(
            member.initials,
            style: TextStyle(
              color: member.avatarColor,
              fontSize: radius * 0.65,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (showJerseyBadge && member.jerseyNumber != null)
          Positioned(
            bottom: -3,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.smRadius,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: Text(
                '#${member.jerseyNumber}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        if (showOnlineIndicator)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.gray400,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
        if (!member.isActive)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.gray400,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.smRadius,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.gray300),
            const SizedBox(height: AppSpacing.md),
            Text(title,
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.gray500),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle!, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Drag Handle ─────────────────────────────────────────────────────────────

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

