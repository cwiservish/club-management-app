import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';
import '../providers/home_provider.dart';

// ─── Color constants (from Figma) ─────────────────────────────────────────────

const _green  = Color(0xFF0ACB97);
const _orange = Color(0xFFFD8F4B);
const _red    = Color(0xFFFF5858);
const _gray   = Color(0xFF4E5663);

// ─── RSVP 3-button row ────────────────────────────────────────────────────────

class RsvpRow extends StatelessWidget {
  final int goingCount;
  final int maybeCount;
  final int noCount;
  final HomeRsvp selected;
  final ValueChanged<HomeRsvp> onSelect;

  const RsvpRow({
    super.key,
    required this.goingCount,
    required this.maybeCount,
    required this.noCount,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RsvpBtn(
            label:       '$goingCount Going',
            activeColor: _green,
            isActive:    selected == HomeRsvp.going,
            radius:      const BorderRadius.only(
              topLeft:    Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            hasDivider: true,
            onTap:      () => onSelect(HomeRsvp.going),
          ),
        ),
        Expanded(
          child: RsvpBtn(
            label:       '$maybeCount Maybe',
            activeColor: _orange,
            isActive:    selected == HomeRsvp.maybe,
            radius:      BorderRadius.zero,
            hasDivider:  true,
            onTap:       () => onSelect(HomeRsvp.maybe),
          ),
        ),
        Expanded(
          child: RsvpBtn(
            label:       '$noCount No',
            activeColor: _red,
            isActive:    selected == HomeRsvp.no,
            radius:      const BorderRadius.only(
              topRight:    Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            hasDivider: false,
            onTap:      () => onSelect(HomeRsvp.no),
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
    final bg = isActive ? activeColor : _gray;

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
              ? const Border(
                  right: BorderSide(color: Color(0xFFF4F4F4), width: 2),
                )
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.headlineSmall.copyWith(
            color:      Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
