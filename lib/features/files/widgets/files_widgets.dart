import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';
import '../models/file_item.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Upload Button
// ══════════════════════════════════════════════════════════════════════════════

class FilesUploadButton extends StatelessWidget {
  final VoidCallback onTap;
  const FilesUploadButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.current.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.current.gray300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.current.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.add, size: 26, color: AppColors.current.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload New File',
              style: AppTextStyles.body15.copyWith(
                color: AppColors.current.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'PDF, Excel, Word up to 10MB',
              style: AppTextStyles.heading12.copyWith(
                color: AppColors.current.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section Label
// ══════════════════════════════════════════════════════════════════════════════

class FilesSectionLabel extends StatelessWidget {
  final String title;
  const FilesSectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.heading14.copyWith(
        color: AppColors.current.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// File Card
// ══════════════════════════════════════════════════════════════════════════════

class FileCard extends StatelessWidget {
  final FileItem file;
  final VoidCallback onDownloadTap;

  const FileCard({super.key, required this.file, required this.onDownloadTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.current.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.gray100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // File icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.current.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomSvgIcon(
                assetPath: AppAssets.fileTextIcon,
                size: 20,
                color: AppColors.current.gray500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: AppTextStyles.body15.copyWith(
                    color: AppColors.current.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${file.size} • ${file.date}',
                  style: AppTextStyles.body13.copyWith(
                    color: AppColors.current.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Download button
          InkWell(
            onTap: onDownloadTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: CustomSvgIcon(
                assetPath: AppAssets.downloadIcon,
                size: 20,
                color: AppColors.current.gray400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
