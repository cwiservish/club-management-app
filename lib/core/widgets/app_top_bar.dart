import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../utils/app_helpers.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSubHeader;
  final String subHeaderTitle;
  final VoidCallback? onBack;

  const AppTopBar({
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
                GestureDetector(
                  onTap: () => AppHelpers.showComingSoonSnackBar(context, 'Profile'),
                  child: Icon(Icons.person_outline, color: textColor, size: 28),
                ),
                const Spacer(),
                // Dropdown Selector
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
                const SizedBox(width: 16),
                Icon(Icons.more_vert, color: textColor, size: 24),
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
