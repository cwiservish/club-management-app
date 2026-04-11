class PhotoAlbum {
  final String name;
  final int photoCount;

  const PhotoAlbum({required this.name, required this.photoCount});
}

class PhotosData {
  final List<PhotoAlbum> albums;

  const PhotosData({required this.albums});
}
