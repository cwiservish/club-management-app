import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_album.dart';
import '../services/photos_service.dart';

class PhotosState {
  final List<PhotoAlbum> albums;
  final int selectedAlbumIndex;

  const PhotosState({
    required this.albums,
    required this.selectedAlbumIndex,
  });

  PhotoAlbum get selectedAlbum => albums[selectedAlbumIndex];

  PhotosState copyWith({List<PhotoAlbum>? albums, int? selectedAlbumIndex}) {
    return PhotosState(
      albums: albums ?? this.albums,
      selectedAlbumIndex: selectedAlbumIndex ?? this.selectedAlbumIndex,
    );
  }
}

class PhotosNotifier extends Notifier<PhotosState> {
  @override
  PhotosState build() {
    final data = ref.read(photosServiceProvider).getPhotosData();
    return PhotosState(albums: data.albums, selectedAlbumIndex: 0);
  }

  void selectAlbum(int index) => state = state.copyWith(selectedAlbumIndex: index);
}

final photosServiceProvider = Provider<PhotosService>((ref) => PhotosService());

final photosProvider = NotifierProvider<PhotosNotifier, PhotosState>(PhotosNotifier.new);
