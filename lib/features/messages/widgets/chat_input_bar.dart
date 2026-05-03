import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onToggleAttach;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.hasText,
    required this.onSend,
    required this.onToggleAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left:   8,
        right:  16,
        top:    8,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 8
            : MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.current.headerBg,
        border: Border(
          top: BorderSide(color: AppColors.current.border, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Attach button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color:  AppColors.current.card,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onToggleAttach,
              icon: Transform.rotate(
                angle: 0.6,
                child: Transform.scale(
                  scaleX: -1,
                  child: Icon(
                    Icons.attach_file,
                    color: AppColors.current.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          // Text field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.current.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: hasText
                      ? AppColors.current.primary
                      : Colors.transparent,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: AppTextStyles.body15.copyWith(
                        color: AppColors.current.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.body15.copyWith(
                          color: AppColors.current.textSecondary
                              .withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.current.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width:  44,
              height: 44,
              decoration: BoxDecoration(
                color: hasText
                    ? AppColors.current.primary
                    : AppColors.current.card,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: hasText ? 0 : -0.6,
                  child: Icon(
                    hasText ? Icons.send : Icons.send_outlined,
                    color: hasText ? Colors.white : AppColors.current.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
