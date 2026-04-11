import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'messages_provider.dart';

/// Total unread message count across all threads.
/// Drives the badge on the Messages tab in [AppBottomNavBar].
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(messagesProvider).totalUnread;
});
