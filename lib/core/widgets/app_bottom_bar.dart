import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final activeColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final inactiveColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final activeBg = isDark ? AppColors.darkCard : const Color(0xFFF0F0F0); // Active tab highlight

    return Container(
      height: 93,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home', activeColor, inactiveColor, activeBg, bgColor),
          _buildNavItem(1, Icons.calendar_month_rounded, 'Schedule', activeColor, inactiveColor, activeBg, bgColor),
          _buildNavItem(2, Icons.person_rounded, 'Roster', activeColor, inactiveColor, activeBg, bgColor),
          _buildNavItem(3, Icons.forum_rounded, 'Messages', activeColor, inactiveColor, activeBg, bgColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
    Color activeBg,
    Color inactiveBg,
  ) {
    final isActive = currentIndex == index;
    final color = isActive ? activeColor : inactiveColor;
    final background = isActive ? activeBg : inactiveBg;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 93,
          color: background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
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
  }
}
