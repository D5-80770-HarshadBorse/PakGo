import 'package:flutter/material.dart';

class NavigationService {
  // Create the GlobalKey for the Navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Helper method for easy access to the BuildContext
  BuildContext get context => navigatorKey.currentContext!;

  // Navigation methods
  Future<dynamic>? pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic>? pushReplacementNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }

  void goBack() {
    return navigatorKey.currentState?.pop();
  }
}
