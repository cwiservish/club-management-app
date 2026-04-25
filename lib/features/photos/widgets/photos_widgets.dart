import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';
import '../models/photo_item.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Photo Grid
// ══════════════════════════════════════════════════════════════════════════════

class PhotosGrid extends StatelessWidget {
  final List<PhotoItem> photos;
  final VoidCallback onUploadTap;

  const PhotosGrid({super.key, required this.photos, required this.onUploadTap});

  @override
  Widget build(BuildContext context) {
    // photos + 1 upload tile
    final itemCount = photos.length + 1;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i < photos.length) {
          return PhotoTile(photo: photos[i]);
        }
        return PhotoUploadTile(onTap: onUploadTap);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Photo Tile
// ══════════════════════════════════════════════════════════════════════════════

class PhotoTile extends StatelessWidget {
  final PhotoItem photo;
  const PhotoTile({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColors.current.gray100,
        child: Image.network(
          photo.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: CustomSvgIcon(
              assetPath: AppAssets.imageIcon,
              size: 32,
              color: AppColors.current.gray400,
            ),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.current.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Upload Tile
// ══════════════════════════════════════════════════════════════════════════════

class PhotoUploadTile extends StatelessWidget {
  final VoidCallback onTap;
  const PhotoUploadTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.current.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.current.gray300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.current.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: AppColors.current.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload Photo',
              style: AppTextStyles.heading13.copyWith(
                color: AppColors.current.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
