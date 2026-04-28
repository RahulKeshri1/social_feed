import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  late SharedPreferences _prefs;

  @override
  ThemeMode build() {
    _initTheme();
    return ThemeMode.system;
  }

  void _initTheme() {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      final saved = prefs.getString('theme_mode');
      if (saved != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.toString().split('.').last == saved,
          orElse: () => ThemeMode.system,
        );
      }
    });
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.toString().split('.').last);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  static Future<ThemeMode> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('theme_mode');
      if (saved != null) {
        return ThemeMode.values.firstWhere(
          (e) => e.toString().split('.').last == saved,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      print('Error loading theme: $e');
    }
    return ThemeMode.system;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

