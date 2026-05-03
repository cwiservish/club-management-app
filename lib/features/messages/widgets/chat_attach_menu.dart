import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class ChatAttachMenu extends StatelessWidget {
  final VoidCallback onClose;

  const ChatAttachMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.image_outlined,        'Photo',    const Color(0xFF0EA5E9)),
      (Icons.camera_alt_outlined,   'Camera',   AppColors.current.emerald),
      (Icons.attach_file,           'File',     AppColors.current.purple),
      (Icons.location_on_outlined,  'Location', AppColors.current.warning),
      (Icons.contact_page_outlined, 'Contact',  AppColors.current.primary),
    ];

    return Container(
      color: AppColors.current.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          Widget icon = Icon(a.$1, color: a.$3, size: 22);
          if (a.$1 == Icons.attach_file) {
            icon = Transform.rotate(
              angle: 0.6,
              child: Transform.scale(scaleX: -1, child: icon),
            );
          }
          return GestureDetector(
            onTap: onClose,
            child: Column(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: a.$3.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(height: 6),
              Text(
                a.$2,
                style: AppTextStyles.label11.copyWith(
                  color: AppColors.current.textSecondary,
                ),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}
