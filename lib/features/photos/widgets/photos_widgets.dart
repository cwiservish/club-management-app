import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';
import '../models/photo_item.dart';
import '../providers/photos_provider.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Photo Grid
// ══════════════════════════════════════════════════════════════════════════════

class PhotosGrid extends StatelessWidget {
  final List<PhotoItem> photos;

  const PhotosGrid({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: photos.length,
      itemBuilder: (_, i) => PhotoTile(photo: photos[i]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Photo Tile (ConsumerWidget with Delete and Lightbox actions)
// ══════════════════════════════════════════════════════════════════════════════

class PhotoTile extends ConsumerWidget {
  final PhotoItem photo;
  const PhotoTile({super.key, required this.photo});

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.current.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Photo',
          style: AppTextStyles.heading16.copyWith(color: AppColors.current.textPrimary),
        ),
        content: Text(
          'Are you sure you want to permanently delete this photo?',
          style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: AppTextStyles.body14.copyWith(color: AppColors.current.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await ref.read(photosProvider.notifier).deletePhoto(photo.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final error = ref.read(photosProvider).errorMessage ?? 'Failed to delete photo';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.current.gray100),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PhotoLightbox(photo: photo)),
                );
              },
              child: Container(
                color: Colors.white,
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
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withOpacity(0.4),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => _confirmDelete(context, ref),
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.white,
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

// ══════════════════════════════════════════════════════════════════════════════
// Photo Lightbox (Pinch-to-zoom full screen viewer)
// ══════════════════════════════════════════════════════════════════════════════

class PhotoLightbox extends StatelessWidget {
  final PhotoItem photo;
  const PhotoLightbox({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            photo.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.error_outline, color: Colors.white, size: 48),
            ),
          ),
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

