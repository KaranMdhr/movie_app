import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';

/// Handles the search field: debounces keystrokes, ignores stale responses
/// and exposes results, loading and error state.
class SearchProvider extends ChangeNotifier {
  SearchProvider(this._service);

  final TmdbService _service;

  /// Time to wait after the last keystroke before calling TMDB.
  static const Duration _debounceDelay = Duration(milliseconds: 450);

  Timer? _debounce;

  /// Incremented on every new search so late responses can be ignored.
  int _requestId = 0;

  String _query = '';
  List<Movie> _results = const [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  bool _disposed = false;

  String get query => _query;
  List<Movie> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;

  /// Called on every keystroke. Restarts the debounce timer.
  void onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _reset();
      return;
    }

    _debounce = Timer(_debounceDelay, () => _search(trimmed));
  }

  /// Called when the user presses the keyboard's search button.
  void submit(String value) {
    _query = value;
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _reset();
      return;
    }
    _search(trimmed);
  }

  /// Clears the field and returns to the initial prompt.
  void clear() {
    _query = '';
    _debounce?.cancel();
    _reset();
  }

  /// Retries the current query after an error.
  Future<void> retry() async {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) return;
    _debounce?.cancel();
    await _search(trimmed);
  }

  Future<void> _search(String query) async {
    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      final results = await _service.searchMovies(query);
      if (requestId != _requestId) return;
      _results = results;
      _hasSearched = true;
    } on ApiException catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = error.message;
      _hasSearched = true;
    } catch (_) {
      if (requestId != _requestId) return;
      _errorMessage = 'Something went wrong while searching.';
      _hasSearched = true;
    } finally {
      // Only the newest request may clear the loading flag.
      if (requestId == _requestId) {
        _isLoading = false;
        _notify();
      }
    }
  }

  void _reset() {
    _requestId++; // invalidate any in-flight request
    _results = const [];
    _isLoading = false;
    _hasSearched = false;
    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _service.dispose();
    super.dispose();
  }
}
