import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tracking_assignment.dart';
import '../services/tracking_service.dart';

final _trackingServiceProvider = Provider<TrackingService>(
  (_) => TrackingService(),
);

final trackingAssignmentsProvider =
    Provider.autoDispose<List<TrackingAssignment>>((ref) {
  return ref.watch(_trackingServiceProvider).getAssignments();
});
