import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  AppColorScheme _colorScheme = AppColorScheme();

  ThemeProvider() {
    _loadColorPreference();
  }

  AppColorScheme get colorScheme => _colorScheme;

  void updateColor(Color newColor) {
    _colorScheme.updateColor(newColor);
    _saveColorPreference(newColor);
    notifyListeners();
  }

  void updatelabelColor(Color labelcolor) {
    _colorScheme.updatelabelColor(labelcolor);
    _saveColorPreference(labelcolor);
    notifyListeners();
  }

  Future<void> _loadColorPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('selectedColor');
    final colorlabelValue = prefs.getInt('labelColor');
    if (colorValue != null) {
      _colorScheme.updateColor(Color(colorValue));
    }if (colorlabelValue != null) {
      _colorScheme.updateColor(Color(colorlabelValue));
    }
  }

  Future<void> _saveColorPreference(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedColor', color.value);
    await prefs.setInt('labelColor', color.value);
  }

}


class AppColorScheme with ChangeNotifier {
  Color _selectedColor = Colors.blue;
  Color _selectedLabelColor = Colors.grey;

  Color get selectedColor => _selectedColor;
  Color get selectedLabelColor => _selectedLabelColor;

  void updateColor(Color newColor) {
    _selectedColor = newColor;
    notifyListeners();
  }
  void updatelabelColor(Color labelcolor) {
    _selectedLabelColor = labelcolor;
    notifyListeners();
  }
}