import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Section Label
// ══════════════════════════════════════════════════════════════════════════════

class NotificationSectionLabel extends StatelessWidget {
  final String title;
  const NotificationSectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.heading14.copyWith(
          color: AppColors.current.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Notification Card Container
// ══════════════════════════════════════════════════════════════════════════════

class NotificationCard extends StatelessWidget {
  final List<Widget> children;
  const NotificationCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.current.gray100),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Email Notification Row (dropdown selector style)
// ══════════════════════════════════════════════════════════════════════════════

class NotificationEmailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;
  const NotificationEmailRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: AppColors.current.gray100))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body15.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTextStyles.body15.copyWith(
                    color: AppColors.current.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 12,
                      child: Icon(Icons.expand_less,
                          size: 16, color: AppColors.current.primary),
                    ),
                    SizedBox(
                      height: 12,
                      child: Icon(Icons.expand_more,
                          size: 16, color: AppColors.current.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Toggle Row
// ══════════════════════════════════════════════════════════════════════════════

class NotificationToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;
  const NotificationToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: AppColors.current.gray100))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body15.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          NotificationToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Toggle Widget
// ══════════════════════════════════════════════════════════════════════════════

class NotificationToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const NotificationToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 51,
        height: 31,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.current.rsvpGoing : AppColors.current.gray300,
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Info Box
// ══════════════════════════════════════════════════════════════════════════════

class NotificationInfoBox extends StatelessWidget {
  const NotificationInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.current.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: AppColors.current.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'i',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: AppColors.current.primary,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your notification preferences apply to everyone using the same email to access Playbook365.',
              style: AppTextStyles.body13.copyWith(
                color: AppColors.current.gray700,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
