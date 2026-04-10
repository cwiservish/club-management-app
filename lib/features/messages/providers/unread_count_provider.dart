import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/sample_data.dart';

/// Total unread message count across all threads.
/// Drives the badge on the Messages tab in [AppBottomNavBar].
///
/// Replace the body with a real stream/notifier once backend is wired.
final unreadCountProvider = Provider<int>((ref) {
  return sampleThreads.fold(0, (sum, t) => sum + t.unreadCount);
});
