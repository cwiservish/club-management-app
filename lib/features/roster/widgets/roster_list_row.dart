import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/roster_member.dart';
import '../../../core/enums/member_role.dart';

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
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.current.border.withOpacity(0.5), width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.current.gray300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.current.border.withOpacity(0.4),
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                member.initials,
                style: AppTextStyles.heading14.copyWith(
                  color: AppColors.current.gray500,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + chips
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: AppTextStyles.body16.copyWith(
                      color: AppColors.current.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: _buildChips(),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right,
              color: AppColors.current.gray400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChips() {
    if (member.role == MemberRole.player) {
      return [
        if (member.jerseyNumber != null) ...[
          _Chip(label: '#${member.jerseyNumber}'),
          const SizedBox(width: 6),
        ],
        if (member.positionFull.isNotEmpty)
          _Chip(label: member.positionFull),
      ];
    } else {
      return [
        if (member.staffTitle != null) _Chip(label: member.staffTitle!),
      ];
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.current.gray100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.label13.copyWith(
          color: AppColors.current.gray500,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
