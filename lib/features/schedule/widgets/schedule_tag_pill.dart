import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';

class ScheduleTagPill extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const ScheduleTagPill({
    super.key,
    required this.text,
    this.bgColor = const Color(0xFFD9FBFF),
    this.textColor = const Color(0xFF006399),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.label11.copyWith(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}
