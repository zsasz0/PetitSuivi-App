import 'package:flutter/material.dart';

// File: drawer_nav_observer.dart
// Purpose: Monitors navigation to auto-hide the drawer menu button (hamburger).
// Usage: Observer for the Navigator in CombinedHomeScreen.
// API Usage: No.
// Dependencies: None.

/// An observer that hides the drawer toggle when the navigator has a back stack.
class DrawerNavObserver extends NavigatorObserver {
  final ValueNotifier<bool> visibility;

  DrawerNavObserver(this.visibility);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateVisibility();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateVisibility();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateVisibility();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateVisibility();
  }

  void _updateVisibility() {
    Future.microtask(() {
      visibility.value = !(navigator?.canPop() ?? false);
    });
  }
}
