import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/roster_member.dart';

class RosterListRow extends StatelessWidget {
  final RosterMember member;
  final VoidCallback onTap;

  const RosterListRow({super.key, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 77,
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.current.card, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.current.card,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                member.initials,
                style: AppTextStyles.heading18.copyWith(
                  color: AppColors.current.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: AppTextStyles.body16.copyWith(color: AppColors.current.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.jerseyNumber != null
                        ? '#${member.jerseyNumber}'
                        : member.staffTitle ?? '',
                    style: AppTextStyles.body13.copyWith(
                        color: AppColors.current.textPrimary.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.current.textPrimary.withOpacity(0.35), size: 20),
          ],
        ),
      ),
    );
  }
}
