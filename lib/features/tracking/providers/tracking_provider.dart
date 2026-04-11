import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tracking_item.dart';
import '../services/tracking_service.dart';

final trackingServiceProvider = Provider<TrackingService>((ref) => TrackingService());

final trackingProvider = FutureProvider<List<TrackingItem>>((ref) async {
  return ref.read(trackingServiceProvider).getItems();
});
