import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../constants/app_assets.dart';
import 'custom_svg_icon.dart';


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
    final activeBgColor = AppColors.current.card;
    final inactiveBgColor = AppColors.current.background;
    final activeColor = AppColors.current.navActive;
    final inactiveColor = AppColors.current.textPrimary;

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        border: Border(
          top: BorderSide(color: AppColors.current.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
          if (bottomInset > 0)
            Container(
              height: bottomInset,
              color: AppColors.current.surface,
            ),
        ],
      ),
    );
  }
}
