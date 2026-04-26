import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

const _tabs = ['All', 'Pending', 'Overdue', 'Paid'];

class InvoiceTabBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const InvoiceTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.current.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Row(
        children: _tabs.map((tab) {
          final isActive = tab == activeTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? AppColors.current.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: AppTextStyles.body13.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? AppColors.current.primary
                        : AppColors.current.gray500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
