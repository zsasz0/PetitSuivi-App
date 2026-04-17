import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  bool _isMounted = true;

  void setSelectedIndex(int index, {VoidCallback? onPageChanged}) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
      onPageChanged?.call();
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  bool get mounted => _isMounted;
}
