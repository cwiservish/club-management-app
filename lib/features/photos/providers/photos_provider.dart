import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_item.dart';
import '../services/photos_service.dart';

final _photosServiceProvider = Provider<PhotosService>((_) => PhotosService());

final photosProvider = Provider.autoDispose<List<PhotoItem>>((ref) {
  return ref.watch(_photosServiceProvider).getPhotos();
});
