import '../models/photo_item.dart';

class PhotosService {
  List<PhotoItem> getPhotos() {
    return const [
      PhotoItem(
        id: '1',
        imageUrl: 'https://images.unsplash.com/photo-1764239810857-afc41f436cc8?w=400&q=80',
      ),
      PhotoItem(
        id: '2',
        imageUrl: 'https://images.unsplash.com/photo-1622659097509-4d56de14539e?w=400&q=80',
      ),
      PhotoItem(
        id: '3',
        imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbb1925813?w=400&q=80',
      ),
      PhotoItem(
        id: '4',
        imageUrl: 'https://images.unsplash.com/photo-1551280857-2b9bbe520442?w=400&q=80',
      ),
    ];
  }
}
