import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class EventEditToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDanger;

  const EventEditToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors      = AppColors.current;
    final activeColor = isDanger ? colors.error : colors.rsvpGoing;
    final trackColor  = value ? activeColor : colors.gray300;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:  48,
        height: 28,
        decoration: BoxDecoration(
          color:        trackColor,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedAlign(
          duration:  const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width:  20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
