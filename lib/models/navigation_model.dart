import 'package:flutter/material.dart';
import 'package:store_manager/routing/route_names.dart';

List<NavigationModel> navigationItems = [
  NavigationModel(
      title: "Billing", icon: Icons.money, routeName: BillTransRoute),
  NavigationModel(
      title: "Stocks", icon: Icons.bar_chart, routeName: StocksRoute),
  NavigationModel(
      title: "Customers",
      icon: Icons.person_add_alt,
      routeName: CustomersRoute),
  NavigationModel(title: "Settings", icon: Icons.settings, routeName: ""),
];

class NavigationModel extends ChangeNotifier {
  final String title;
  final IconData icon;
  final String routeName;

  int currentScreenIndex = 0;
  void updateCurrentScreenIndex(int index) {
    currentScreenIndex = index;
    notifyListeners();
  }

  List<int> indexStack = [];

  void addToStack(int index) {
    indexStack.add(index);
    notifyListeners();
  }

  void resetIndexStack() {
    indexStack = [];
    notifyListeners();
  }

  int popFromStack() {
    indexStack.removeLast();
    int lastIndex = indexStack[indexStack.length - 1];
    notifyListeners();
    return lastIndex;
  }

  NavigationModel({this.routeName, this.title, this.icon});
}
