import '../models/photo_album.dart';

class PhotosService {
  PhotosData getPhotosData() => const PhotosData(
        albums: [
          PhotoAlbum(name: 'All Photos', photoCount: 21),
          PhotoAlbum(name: 'vs. Riverside FC', photoCount: 8),
          PhotoAlbum(name: 'Practice Mar 25', photoCount: 7),
          PhotoAlbum(name: 'Spring 2026', photoCount: 6),
        ],
      );
}
