import 'package:flutter/material.dart';

class ToggleNavBar extends ChangeNotifier {
  bool _show = true;

  bool getShow() => _show;
  updateShow(bool b) {
    _show = b;
    notifyListeners();
  }

  toggleShow() {
    _show = !_show;
    notifyListeners();
  }
}
