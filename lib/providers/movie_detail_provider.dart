import 'package:material_ui/material_ui.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';

/// Loads the full detail payload for one movie.
///
/// Created per detail screen (see the `/movie/:id` route) so each page owns
/// its own loading + error state.
class MovieDetailProvider extends ChangeNotifier {
  MovieDetailProvider(
    this._service,
    this.movieId, {
    Movie? initialMovie,
  }) : _movie = initialMovie;

  final TmdbService _service;
  final int movieId;

  Movie? _movie;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  bool _disposed = false;

  Movie? get movie => _movie;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool showLoading = true}) async {
    if (movieId <= 0) {
      _errorMessage = 'Invalid movie id.';
      _hasLoaded = true;
      _notify();
      return;
    }

    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      _notify();
    }

    try {
      _movie = await _service.fetchMovieDetail(movieId);
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading this movie.';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      _notify();
    }
  }

  Future<void> retry() => load();

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
