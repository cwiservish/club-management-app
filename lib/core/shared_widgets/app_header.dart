import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../common_providers/theme_provider.dart';
import '../constants/app_assets.dart';
import 'account_drawer.dart';
import 'custom_svg_icon.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final textColor = AppColors.current.textPrimary;
    final borderColor = AppColors.current.border;
    final pillBgColor = AppColors.current.card;

    return Container(
      height: 53 + topPadding,
      decoration: BoxDecoration(
        color: AppColors.current.headerBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => showAccountDrawer(context),
            child: CustomSvgIcon(
              assetPath: AppAssets.rosterIcon,
              color: textColor,
              size: 24,
            ),
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
            child: Row(
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
                const SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down, color: textColor, size: 20),
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: toggleAppTheme,
            child: CustomSvgIcon(
              assetPath: AppAssets.plusIcon,
              color: textColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => context.go(AppRoutes.settings),
            child: Icon(
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
