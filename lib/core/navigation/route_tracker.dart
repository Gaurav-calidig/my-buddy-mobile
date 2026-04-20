import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Navigator observer for tracking current route state.
///
/// Monitors navigation events and maintains a reference to the current route.
/// Provides debug logging in development mode for navigation tracking.
class RouteTracker extends NavigatorObserver {
  /// The currently active route name
  static String? currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute = route.settings.name;
    if(kDebugMode) {
      debugPrint('➡️ Pushed: $currentRoute');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute = previousRoute?.settings.name;
    if(kDebugMode) {
      debugPrint('⬅️ Popped to: $currentRoute');
    }
  }

// Additional navigation events can be tracked here if needed:
// didReplace, didRemove, etc.
}
