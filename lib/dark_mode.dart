import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyTheme with ChangeNotifier {
  static bool _isDark = true;

  ThemeData currentTheme() {
    return _isDark
        ? ThemeData.dark()
        : ThemeData(
            primaryColor: Colors.red,
          );
  }

  void switchTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
