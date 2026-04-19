import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class RsvpSection extends StatelessWidget {
  final String selected; // 'going' | 'maybe' | 'no'
  final ValueChanged<String> onSelect;

  const RsvpSection({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR ATTENDANCE',
            style: AppTextStyles.overline.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _RsvpButton(
                    label: 'Going',
                    value: 'going',
                    selected: selected,
                    activeColor: AppColors.current.rsvpGoing,
                    onTap: onSelect,
                  ),
                  VerticalDivider(width: 1, color: colors.border.withValues(alpha: 0.5)),
                  _RsvpButton(
                    label: 'Maybe',
                    value: 'maybe',
                    selected: selected,
                    activeColor: AppColors.current.rsvpMaybe,
                    onTap: onSelect,
                  ),
                  VerticalDivider(width: 1, color: colors.border.withValues(alpha: 0.5)),
                  _RsvpButton(
                    label: 'No',
                    value: 'no',
                    selected: selected,
                    activeColor: AppColors.current.rsvpNo,
                    onTap: onSelect,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RsvpButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color activeColor;
  final ValueChanged<String> onTap;

  const _RsvpButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected == value;
    final colors = AppColors.current;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          color: isActive ? activeColor : colors.background,
          child: Text(
            label,
            style: AppTextStyles.heading14.copyWith(
              color: isActive ? Colors.white : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
