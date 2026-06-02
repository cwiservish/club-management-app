import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/member_role.dart';
import '../providers/roster_provider.dart';

class RosterSortBottomSheet extends ConsumerWidget {
  final MemberRole role;
  const RosterSortBottomSheet({super.key, required this.role});

  static const _playerOptions = [
    'First Name',
    'Last Name',
    'Position',
    'Gender',
    'Number',
  ];

  static const _staffOptions = [
    'First Name',
    'Last Name',
    'Gender',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rosterProvider);
    final isPlayer = role == MemberRole.player;
    final selected = isPlayer ? state.sortBy : state.staffSortBy;
    final options = isPlayer ? _playerOptions : _staffOptions;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.current.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Sort Roster By',
                  style: AppTextStyles.heading18.copyWith(
                    color: AppColors.current.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.current.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.current.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.current.border.withOpacity(0.5)),
          // Options
          Padding(
            padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              children: options.map((option) {
                final isSelected = selected == option;
                return GestureDetector(
                  onTap: () {
                    if (isPlayer) {
                      ref.read(rosterProvider.notifier).setSortBy(option);
                    } else {
                      ref.read(rosterProvider.notifier).setStaffSortBy(option);
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.current.primaryLight
                          : AppColors.current.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.current.primary.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          option,
                          style: AppTextStyles.body16.copyWith(
                            color: isSelected
                                ? AppColors.current.primary
                                : AppColors.current.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.current.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.current.isDark
                                  ? AppColors.current.gray900
                                  : Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
