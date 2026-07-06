import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/photos_provider.dart';
import '../widgets/photos_widgets.dart';
import '../../files/widgets/files_widgets.dart';

class PhotosPage extends ConsumerWidget {
  const PhotosPage({super.key});

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final success = await ref.read(photosProvider.notifier).uploadPhoto(pickedFile.path);
        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            final error = ref.read(photosProvider).errorMessage ?? 'Failed to upload photo';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.current.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.current.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Photo',
                style: AppTextStyles.heading16.copyWith(
                  color: AppColors.current.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: AppColors.current.primary),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.body15.copyWith(color: AppColors.current.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(context, ref, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: AppColors.current.primary),
                title: Text(
                  'Take a Photo',
                  style: AppTextStyles.body15.copyWith(color: AppColors.current.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(context, ref, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final photosState = ref.watch(photosProvider);

    return Scaffold(
      backgroundColor: AppColors.current.card,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                const AppHeader(),
                SubHeader(
                  title: 'Photos',
                  rightWidget: InkWell(
                    onTap: () => _showImageSourceBottomSheet(context, ref),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.add, size: 24, color: AppColors.current.primary),
                    ),
                  ),
                ),
                Expanded(
                  child: photosState.isLoading && photosState.photos.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.current.primary,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref.read(photosProvider.notifier).refresh(),
                          color: AppColors.current.primary,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(19),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FilesUploadButton(
                                  onTap: () => _showImageSourceBottomSheet(context, ref),
                                  title: 'Upload Photo',
                                  subtitle: 'JPG, PNG up to 10MB',
                                ),
                                const SizedBox(height: 24),
                                const FilesSectionLabel(title: 'Recent Photos'),
                                const SizedBox(height: 12),
                                if (photosState.photos.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 40),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.photo_outlined,
                                            size: 48,
                                            color: AppColors.current.gray400,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No photos found',
                                            style: AppTextStyles.body15.copyWith(
                                              color: AppColors.current.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  PhotosGrid(photos: photosState.photos),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
            if (photosState.isUploading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    color: AppColors.current.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.current.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Uploading photo...',
                            style: AppTextStyles.body15.copyWith(
                              color: AppColors.current.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

