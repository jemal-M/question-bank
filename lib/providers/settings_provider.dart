import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = false;

  bool get darkMode => _darkMode;

  void setDarkMode(bool value) {
    if (_darkMode == value) return;
    _darkMode = value;
    notifyListeners();
  }
}
