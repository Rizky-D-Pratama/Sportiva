import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _preferenceKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_preferenceKey);

      _themeMode = switch (savedMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (error) {
      debugPrint('Gagal memuat preferensi tema: $error');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_preferenceKey, mode.name);
    } catch (error) {
      debugPrint('Gagal menyimpan preferensi tema: $error');
    }
  }
}


class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();

    assert(scope != null, 'ThemeControllerScope tidak ditemukan.');

    return scope!.notifier!;
  }
}