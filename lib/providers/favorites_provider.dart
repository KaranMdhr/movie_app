import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

/// Stores favorite movies locally with shared_preferences.
///
/// Favorites are serialized as a JSON list of [Movie.toJson] maps, so the
/// app can render the Favorites grid instantly on the next launch.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider() {
    _restoreFuture = _restore();
  }

  static const String _prefsKey = 'favorite_movies';

  late final Future<void> _restoreFuture;

  List<Movie> _favorites = const [];
  bool _isLoading = true;
  bool _disposed = false;

  List<Movie> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  bool get isEmpty => _favorites.isEmpty;

  bool isFavorite(int movieId) {
    return _favorites.any((movie) => movie.id == movieId);
  }

  /// Adds the movie to the top of the list, or removes it if already saved.
  Future<void> toggle(Movie movie) async {
    // Never write before the saved list has been read, or we would wipe it.
    await _restoreFuture;

    if (isFavorite(movie.id)) {
      _favorites = _favorites.where((item) => item.id != movie.id).toList();
    } else {
      _favorites = [movie, ..._favorites];
    }

    _notify();
    await _persist();
  }

  Future<void> remove(int movieId) async {
    await _restoreFuture;
    _favorites = _favorites.where((item) => item.id != movieId).toList();
    _notify();
    await _persist();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _favorites = decoded
              .whereType<Map<String, dynamic>>()
              .map(Movie.fromJson)
              .toList();
        }
      } catch (_) {
        // Corrupted storage should never crash the app.
        _favorites = const [];
      }
    }

    _isLoading = false;
    _notify();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_favorites.map((movie) => movie.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
