import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _colorKey = 'theme_color';
  static const String _modeKey = 'theme_mode';

  late Color _primaryColor;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _primaryColor = Color.fromRGBO(241, 218, 221, 1);
    loadTheme();
  }

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0F0F0F),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),

    scaffoldBackgroundColor: Colors.black,
  );

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.inter(
        color: Colors.grey.shade900,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ).apply(bodyColor: Colors.black, displayColor: Colors.grey.shade500),
  );

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    saveThemeModedata(mode);
    notifyListeners();
  }

  void changeColor(Color color) {
    _primaryColor = color;
    saveThemeColor(color);
    notifyListeners();
  }

  Future<void> saveThemeColor(Color color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt(_colorKey, color.value);
    } catch (_) {}
  }

  Future<void> saveThemeModedata(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_modeKey, mode.toString().split('.').last);
    } catch (_) {}
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    String? modeString = prefs.getString(_modeKey);
    if (modeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString().split('.').last == modeString,
        orElse: () => ThemeMode.system,
      );
    }
    notifyListeners();
  }
}
