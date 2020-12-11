import 'package:flutter/material.dart';

class NavigationModel extends ChangeNotifier {
  final String title;
  final IconData icon;

  int _screenIndex = 0;
  int getScreenIndex() => _screenIndex;
  void updateScreenIndex(int index) {
    _screenIndex = index;
    notifyListeners();
  }

  bool isCollapsed = true;
  bool getIsCollapsed() => isCollapsed;
  toggleIsCollapsed() {
    isCollapsed = !isCollapsed;
    notifyListeners();
  }

  NavigationModel({this.title, this.icon});
}

List<NavigationModel> navigationItems = [
  NavigationModel(title: "Billing", icon: Icons.money),
  NavigationModel(title: "Stocks", icon: Icons.bar_chart),
  NavigationModel(title: "Customers", icon: Icons.person_add_alt),
  NavigationModel(title: "Settings", icon: Icons.settings),
];
