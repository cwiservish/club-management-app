import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A shared signal that any feature can increment to notify others that event
/// data has changed. Listeners should re-fetch their event data when this fires.
class EventRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void signal() => state++;
}

final eventRefreshSignalProvider =
    NotifierProvider<EventRefreshNotifier, int>(EventRefreshNotifier.new);
