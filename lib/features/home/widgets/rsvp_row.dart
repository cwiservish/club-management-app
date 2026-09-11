import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/home_provider.dart';

// ─── RSVP 3-button row ────────────────────────────────────────────────────────

class RsvpRow extends StatelessWidget {
  final int goingCount;
  final int maybeCount;
  final int noCount;
  final HomeRsvp selected;
  final bool isLoading;
  final ValueChanged<HomeRsvp> onSelect;

  const RsvpRow({
    super.key,
    required this.goingCount,
    required this.maybeCount,
    required this.noCount,
    required this.selected,
    this.isLoading = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: RsvpBtn(
                label:       '$goingCount Going',
                activeColor: colors.rsvpGoing,
                isActive:    selected == HomeRsvp.going,
                radius:      const BorderRadius.only(
                  topLeft:    Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                hasDivider: true,
                onTap:      isLoading ? () {} : () => onSelect(HomeRsvp.going),
              ),
            ),
            Expanded(
              child: RsvpBtn(
                label:       '$maybeCount Maybe',
                activeColor: colors.rsvpMaybe,
                isActive:    selected == HomeRsvp.maybe,
                radius:      BorderRadius.zero,
                hasDivider:  true,
                onTap:       isLoading ? () {} : () => onSelect(HomeRsvp.maybe),
              ),
            ),
            Expanded(
              child: RsvpBtn(
                label:       '$noCount No',
                activeColor: colors.rsvpNo,
                isActive:    selected == HomeRsvp.no,
                radius:      const BorderRadius.only(
                  topRight:    Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                hasDivider: false,
                onTap:      isLoading ? () {} : () => onSelect(HomeRsvp.no),
              ),
            ),
          ],
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: (colors.isDark ? Colors.black : Colors.white).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Single RSVP button ───────────────────────────────────────────────────────

class RsvpBtn extends StatelessWidget {
  final String label;
  final Color activeColor;
  final bool isActive;
  final BorderRadius radius;
  final bool hasDivider;
  final VoidCallback onTap;

  const RsvpBtn({
    super.key,
    required this.label,
    required this.activeColor,
    required this.isActive,
    required this.radius,
    required this.hasDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? activeColor : AppColors.current.rsvpUnselected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:  const Duration(milliseconds: 180),
        curve:     Curves.easeInOut,
        height:    37,
        decoration: BoxDecoration(
          color:         bg,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset:     const Offset(0, 1),
            ),
          ],
          border: hasDivider
              ? Border(
                  right: BorderSide(color: AppColors.current.card, width: 2),
                )
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.heading16.copyWith(
            color:      Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
