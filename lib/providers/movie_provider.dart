import 'package:material_ui/material_ui.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';

/// Owns the list of movies, the loading flag and the error message.
///
/// Screens listen to this class instead of performing HTTP calls themselves.
class MovieProvider extends ChangeNotifier {
  MovieProvider(this._service);

  final TmdbService _service;

  List<Movie> _movies = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Movie> get movies => List.unmodifiable(_movies);
  bool get isLoading => _isLoading;

  /// False only before the very first response has arrived.
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  bool get hasMovies => _movies.isNotEmpty;

  /// Fetches this week's trending movies.
  ///
  /// Set [showLoading] to false for pull-to-refresh so the grid stays visible.
  Future<void> loadTrending({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      _notify();
    }

    try {
      _movies = await _service.fetchTrendingMovies();
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading movies.';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      _notify();
    }
  }

  Future<void> retry() => loadTrending();

  /// Avoids `notifyListeners()` after the provider was removed from the tree.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _service.dispose();
    super.dispose();
  }
}
