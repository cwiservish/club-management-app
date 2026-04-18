import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../common_providers/theme_provider.dart';
import '../models/roster_member.dart';
import '../constants/app_assets.dart';
import 'custom_svg_icon.dart';

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
    (AppAssets.homeIcon, 'Home'),
    (AppAssets.scheduleIcon, 'Schedule'),
    (AppAssets.rosterIcon, 'Roster'),
    (AppAssets.messageIcon, 'Messages'),
  ];

  @override
  Widget build(BuildContext context) {
    const activeBgColor = Color(0xFFF4F4F4);
    const inactiveBgColor = Color(0xFFFFFFFF);
    const activeColor = Color(0xFF008CFF);
    const inactiveColor = Color(0xFF20242A);

    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(_items.length, (i) {
          final isActive = i == currentIndex;
          final item = _items[i];
          final color = isActive ? activeColor : inactiveColor;
          final background = isActive ? activeBgColor : inactiveBgColor;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                height: 93,
                color: background,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSvgIcon(assetPath: item.$1, color: color, size: 24),
                    const SizedBox(height: 12),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

// ─── App Header ───────────────────────────────────────────────────────────────

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF20242A);
    const borderColor = Color(0xFFD1D1D1);
    const pillBgColor = Color(0xFFF4F4F4);

    return Container(
      height: 53,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomSvgIcon(
            assetPath: AppAssets.rosterIcon,
            color: textColor,
            size: 24,
          ),
          const SizedBox(width: 34),
          const Spacer(),
          Container(
            height: 37,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: pillBgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D101828),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '12 Girls ECNL RL',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    height: 1.25,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down, color: textColor, size: 20),
              ],
            ),
          ),
           Spacer(),
          InkWell(
            onTap: (){
              toggleAppTheme();
            },
            child: const CustomSvgIcon(
              assetPath: AppAssets.plusIcon,
              color: textColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => context.go(AppRoutes.settings),
            child: const Icon(
              Icons.more_vert,
              color: textColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
