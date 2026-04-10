import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _prefKey = 'isLightMode';
  static ThemeManager? _instance;
  
  bool _isLightMode = true;

  ThemeManager._() {
    _loadTheme();
  }

  static ThemeManager get instance {
    _instance ??= ThemeManager._();
    return _instance!;
  }

  bool get isLightMode => _isLightMode;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true (light mode)
    _isLightMode = prefs.getBool(_prefKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isLightMode = !_isLightMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isLightMode);
    notifyListeners();
  }
}
