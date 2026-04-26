import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../common_providers/theme_provider.dart';
import '../constants/app_assets.dart';
import 'account_drawer.dart';
import 'add_menu_dialog.dart';
import 'custom_svg_icon.dart';

class AppHeader extends StatefulWidget {
  final void Function(String team)? onTeamChanged;

  const AppHeader({super.key, this.onTeamChanged});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String _selectedTeam = '12 Girls ECNL RL';

  static const _teams = ['12 Girls ECNL RL', '08 Girls ECNL RL'];

  void _showTeamMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, anim1, anim2) {
        final topPadding = MediaQuery.of(ctx).padding.top;
        final screenWidth = MediaQuery.of(ctx).size.width;
        const dropdownWidth = 240.0;

        return Stack(
          children: [
            Positioned(
              top: topPadding + 53 + 8,
              left: (screenWidth - dropdownWidth) / 2,
              width: dropdownWidth,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.current.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.current.border),
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
                        children: _teams.asMap().entries.map((entry) {
                          final index = entry.key;
                          final team = entry.value;
                          return _TeamOption(
                            name: team,
                            isActive: team == _selectedTeam,
                            borderBottom: index < _teams.length - 1,
                            onTap: () {
                              Navigator.of(ctx).pop();
                              setState(() => _selectedTeam = team);
                              widget.onTeamChanged?.call(team);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) =>
          FadeTransition(opacity: anim1, child: child),
    );
  }

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
          GestureDetector(
            onTap: () => _showTeamMenu(context),
            child: Container(
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
                    _selectedTeam,
                    style: AppTextStyles.body16.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down, color: textColor, size: 20),
                ],
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => showAddMenu(context),
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

class _TeamOption extends StatelessWidget {
  final String name;
  final bool isActive;
  final bool borderBottom;
  final VoidCallback onTap;

  const _TeamOption({
    required this.name,
    required this.isActive,
    required this.borderBottom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: AppColors.current.border))
              : null,
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          name,
          style: AppTextStyles.body16.copyWith(
            color: AppColors.current.textPrimary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
