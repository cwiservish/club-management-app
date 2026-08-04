import 'package:flutter/widgets.dart';

/// Global key to access the root navigator state from anywhere in the codebase.
/// Used specifically for displaying global dialogs/alerts without a BuildContext (e.g. from network interceptors).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
