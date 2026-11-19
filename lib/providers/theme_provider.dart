import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the app's [ThemeMode] and persists it between launches.
///
/// Provider + ChangeNotifier play the same role as a React context holding
/// state: widgets listen here instead of passing the theme down manually.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _restore();
  }

  /// Must stay stable forever: changing it would lose saved preferences.
  static const String _prefsKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// Flips to the opposite theme of whatever the user currently sees.
  ///
  /// [isCurrentlyDark] comes from `Theme.of(context).brightness`, which also
  /// resolves correctly when the app is following the system theme.
  Future<void> toggleTheme(bool isCurrentlyDark) async {
    _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _persist();
  }

  /// Reads the saved choice and rebuilds listeners once it is available.
  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == null) return;

    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _themeMode.name);
  }
}
