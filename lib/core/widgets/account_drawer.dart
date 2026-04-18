import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../common_providers/theme_provider.dart';
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

class _Header extends StatelessWidget {
  final AppColors colors;
  const _Header({required this.colors});

  @override
  Widget build(BuildContext context) {
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
                'Ayla Becher',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  height: 1.2,
                ),
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
                      'Player',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.isDark
                            ? colors.actionAccent
                            : colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ayla@example.com',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.gray500,
                    ),
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

class _Content extends StatelessWidget {
  final AppColors colors;
  const _Content({required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Team Profile row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _NavRow(
            svgAsset: AppAssets.rosterIcon,
            iconBg: colors.isDark
                ? const Color(0xFF008CFF).withValues(alpha: 0.1)
                : const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF008CFF),
            title: 'Team Profile',
            subtitle: 'View stats and details',
            colors: colors,
            onTap: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: 24),

        // SportID Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SPORTID CARD',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.gray400,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),
              const _SportIdCard(),
            ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: colors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.gray400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── SportID Card ─────────────────────────────────────────────────────────────

class _SportIdCard extends StatelessWidget {
  const _SportIdCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20242A), Color(0xFF3A414C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Player photo area (right side)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 130,
              child: Stack(
                children: [
                  Container(color: const Color(0xFF2B3038)),
                  // Gradient fade from card bg to transparent
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF20242A), Colors.transparent],
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),

            // Top: logo text
            const Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Playbook365',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Bottom left: QR + ID
            Positioned(
              left: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      size: 28,
                      color: Color(0xFF20242A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        '#84729-110',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('·', style: TextStyle(color: Colors.white30)),
                      SizedBox(width: 6),
                      Text(
                        '2025-2026',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final AppColors colors;
  const _Footer({required this.colors});

  @override
  Widget build(BuildContext context) {
    final isDark = colors.isDark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            onTap: () {},
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.border.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 4),
          _FooterRow(
            svgAsset: AppAssets.userMinusIcon,
            label: 'Leave team',
            colors: colors,
            isDestructive: true,
            onTap: () {},
          ),
          _FooterRow(
            svgAsset: AppAssets.trashIcon,
            label: 'Delete account',
            colors: colors,
            isDestructive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _FooterRow extends StatefulWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final AppColors colors;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback onTap;

  const _FooterRow({
    this.icon,
    this.svgAsset,
    required this.label,
    required this.colors,
    this.trailing,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  State<_FooterRow> createState() => _FooterRowState();
}

class _FooterRowState extends State<_FooterRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final color = widget.isDestructive
        ? (colors.isDark ? colors.rsvpNo : const Color(0xFFDC2626))
        : colors.textPrimary;

    final iconColor = widget.isDestructive ? color : colors.gray500;
    final iconWidget = widget.svgAsset != null
        ? CustomSvgIcon(assetPath: widget.svgAsset!, color: iconColor, size: 20)
        : Icon(widget.icon, size: 20, color: iconColor);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.isDestructive ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.isDestructive ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.isDestructive ? () => setState(() => _pressed = false) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            AnimatedScale(
              scale: (widget.isDestructive && _pressed) ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: iconWidget,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: widget.isDestructive ? 14 : 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
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
