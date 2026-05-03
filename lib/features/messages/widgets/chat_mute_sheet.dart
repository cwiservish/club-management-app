import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class ChatMuteSheet extends StatelessWidget {
  const ChatMuteSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Mute conversation for',
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.current.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.current.border),
            _MuteOption(label: '2 hours'),
            Divider(height: 1, color: AppColors.current.border),
            _MuteOption(label: '4 hours'),
            Divider(height: 1, color: AppColors.current.border),
            _MuteOption(label: 'Until Tomorrow'),
            Divider(height: 1, color: AppColors.current.border),
            _MuteOption(label: 'Until I Unmute'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MuteOption extends StatelessWidget {
  final String label;
  const _MuteOption({required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body16.copyWith(
            color: AppColors.current.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
