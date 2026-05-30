import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../common_providers/theme_provider.dart';
import '../common_providers/current_user_provider.dart';
import '../common_providers/selected_team_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../constants/app_assets.dart';
import 'custom_svg_icon.dart';

// ─── Public entry point ───────────────────────────────────────────────────────

void showAccountDrawer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const _AccountDrawer(),
    transitionBuilder: (_, animation, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

// ─── Root drawer widget ───────────────────────────────────────────────────────

class _AccountDrawer extends ConsumerWidget {
  const _AccountDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final colors = AppColors.current;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(4, 0),
              ),
            ],
          ),
          child: SafeArea(
            right: false,
            child: Column(
              children: [
                _Header(colors: colors),
                Expanded(child: _Content(colors: colors)),
                _Footer(colors: colors),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final AppColors colors;
  const _Header({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 28, 24),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: colors.border,
                child: Icon(Icons.person, size: 44, color: colors.textPrimary),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                user?.displayName ?? 'User',
                style: AppTextStyles.heading22.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.isDark
                          ? colors.actionAccent.withValues(alpha: 0.1)
                          : colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user?.role.name.toUpperCase() ?? 'PLAYER',
                      style: AppTextStyles.heading14.copyWith(
                        color: colors.isDark ? colors.actionAccent : colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.label13.copyWith(color: colors.gray500),
                  ),
                ],
              ),
            ],
          ),
          // Close button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 20, color: colors.gray500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _Content extends ConsumerWidget {
  final AppColors colors;
  const _Content({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTeam = ref.watch(selectedTeamProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (selectedTeam != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _NavRow(
              svgAsset: AppAssets.rosterIcon,
              iconBg: colors.isDark
                  ? const Color(0xFF008CFF).withValues(alpha: 0.1)
                  : const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF008CFF),
              title: 'Profile Detail',
              subtitle: 'View stats and details',
              colors: colors,
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.profileDetail, extra: selectedTeam.url);
              },
            ),
          ),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  final String svgAsset;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final AppColors colors;
  final VoidCallback onTap;

  const _NavRow({
    required this.svgAsset,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hoverBg = colors.isDark ? colors.card : const Color(0xFFF9FAFB);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: hoverBg,
        highlightColor: hoverBg,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Center(
                child: CustomSvgIcon(assetPath: svgAsset, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading16.copyWith(color: colors.textPrimary)),
                  Text(subtitle, style: AppTextStyles.label12.copyWith(color: colors.gray500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.gray400, size: 20),
          ],
        ),
      ),
    ),);
  }
}



// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends ConsumerWidget {
  final AppColors colors;
  const _Footer({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = colors.isDark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _FooterRow(
            icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            label: 'Dark mode',
            colors: colors,
            trailing: _ThemeSwitch(isDark: isDark, colors: colors),
            onTap: toggleAppTheme,
          ),
          _FooterRow(
            svgAsset: AppAssets.logoutIcon,
            label: 'Log out',
            colors: colors,
            onTap: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final AppColors colors;
  final Widget? trailing;
  final VoidCallback onTap;

  const _FooterRow({
    this.icon,
    this.svgAsset,
    required this.label,
    required this.colors,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colors.textPrimary;
    final overlayColor = colors.isDark ? colors.card : const Color(0xFFF9FAFB);
    final iconColor = colors.gray500;

    final iconWidget = svgAsset != null
        ? CustomSvgIcon(assetPath: svgAsset!, color: iconColor, size: 20)
        : Icon(icon, size: 20, color: iconColor);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: overlayColor,
        highlightColor: overlayColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              iconWidget,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.heading15.copyWith(color: color),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}


// ─── Theme switch ─────────────────────────────────────────────────────────────

class _ThemeSwitch extends StatelessWidget {
  final bool isDark;
  final AppColors colors;
  const _ThemeSwitch({required this.isDark, required this.colors});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 24,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF008CFF) : colors.gray300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
