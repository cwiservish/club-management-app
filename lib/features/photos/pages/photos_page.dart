import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../providers/photos_provider.dart';
import '../widgets/photos_widgets.dart';

class PhotosPage extends ConsumerWidget {
  const PhotosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final photos = ref.watch(photosProvider);

    return Scaffold(
      backgroundColor: AppColors.current.surface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title: 'Photos',
              rightWidget: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.add, size: 24, color: AppColors.current.primary),
                ),
              ),
            ),
            Expanded(
              child: PhotosGrid(
                photos: photos,
                onUploadTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
