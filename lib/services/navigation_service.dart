import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, bool sameTabPressed) {
    if (!sameTabPressed) return navigatorKey.currentState.pushNamed(routeName);

    return navigatorKey.currentState.popAndPushNamed(routeName);
  }

  void goBack() {
    navigatorKey.currentState.pop();
  }
}
