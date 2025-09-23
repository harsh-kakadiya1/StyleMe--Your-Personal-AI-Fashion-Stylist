import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      primaryColor: const Color(0xFF2C3E50),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2C3E50),
        primary: const Color(0xFF2C3E50),
        secondary: const Color(0xFFD2B48C),
        surface: Colors.white,
        background: const Color(0xFFF7F7F7),
        onBackground: const Color(0xFF2C3E50),
        onSurface: const Color(0xFF2C3E50),
        error: const Color(0xFFE74C3C),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F7F7),
        foregroundColor: Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2C3E50),
        unselectedItemColor: Color(0xFFBDC3C7),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      primaryColor: const Color(0xFF3498DB),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3498DB),
        primary: const Color(0xFF3498DB),
        secondary: const Color(0xFFE67E22),
        surface: const Color(0xFF2C2C2C),
        background: const Color(0xFF1A1A1A),
        onBackground: Colors.white,
        onSurface: Colors.white,
        error: const Color(0xFFE74C3C),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2C2C2C),
        selectedItemColor: Color(0xFF3498DB),
        unselectedItemColor: Color(0xFF7F8C8D),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
