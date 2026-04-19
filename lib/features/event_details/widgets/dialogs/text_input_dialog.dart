import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/shared_widgets/textfield/app_text_field.dart';

/// Shows a modal dialog with an optional subtitle, a textarea, and two buttons.
/// Used for: Add Note, Edit Note, Message All.
Future<void> showTextInputDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  String initialText = '',
  String placeholder = '',
  String primaryLabel = 'Save',
  Widget? primaryIcon,
  required void Function(String text) onConfirm,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _TextInputDialog(
      title: title,
      subtitle: subtitle,
      initialText: initialText,
      placeholder: placeholder,
      primaryLabel: primaryLabel,
      primaryIcon: primaryIcon,
      onConfirm: onConfirm,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String initialText;
  final String placeholder;
  final String primaryLabel;
  final Widget? primaryIcon;
  final void Function(String) onConfirm;

  const _TextInputDialog({
    required this.title,
    this.subtitle,
    required this.initialText,
    required this.placeholder,
    required this.primaryLabel,
    this.primaryIcon,
    required this.onConfirm,
  });

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    // Light: white dialog on grey page. Dark: card (#2b3038) dialog.
    final dialogBg = colors.isDark ? colors.card : colors.background;
    final cancelBg = colors.isDark ? colors.background : colors.gray100;
    final primaryTextColor = colors.isDark ? colors.gray900 : Colors.white;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.heading18.copyWith(color: colors.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cancelBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18, color: colors.textSecondary),
                  ),
                ),
              ],
            ),

            if (widget.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.subtitle!,
                style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
              ),
            ],

            const SizedBox(height: 16),

            // ── Textarea ──────────────────────────────────────────────────────
            AppTextField(
              controller: _controller,
              hintText: widget.placeholder,
              minLines: 4,
              maxLines: 5,
              autofocus: true,
            ),

            const SizedBox(height: 20),

            // ── Actions ───────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: cancelBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onConfirm(_controller.text.trim());
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.primaryIcon != null) ...[
                            widget.primaryIcon!,
                            const SizedBox(width: 6),
                          ],
                          Text(
                            widget.primaryLabel,
                            style: AppTextStyles.heading14.copyWith(color: primaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
