import 'package:flutter/material.dart';
import '../../config/theme/theme_config.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isFeminine = true;

  bool get isFeminine => _isFeminine;
  ThemeData get themeData => ThemeConfig.build(feminine: _isFeminine);

  void setGender(String gender) {
    _isFeminine = gender.toLowerCase() != 'male';
    notifyListeners();
  }

  void toggle() {
    _isFeminine = !_isFeminine;
    notifyListeners();
  }
}
