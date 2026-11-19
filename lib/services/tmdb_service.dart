import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../utils/constants.dart';

/// A user-facing API failure. [message] is safe to show in the UI.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper around the TMDB REST API.
///
/// All HTTP and JSON handling lives here so widgets and providers never
/// touch URLs, status codes or `jsonDecode`.
class TmdbService {
  /// Passing a [client] makes the service testable; production code can
  /// simply call `TmdbService()`.
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 15);

  Future<List<Movie>> fetchTrendingMovies({int page = 1}) async {
    final json = await _get(_uri('/trending/movie/week', {'page': page}));
    return _parseMovieList(json);
  }

  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final json = await _get(_uri('/movie/popular', {'page': page}));
    return _parseMovieList(json);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final trimmed = query.trim();
    // No point hitting the network for an empty search.
    if (trimmed.isEmpty) return const [];

    final json = await _get(
      _uri('/search/movie', {'query': trimmed, 'page': page}),
    );
    return _parseMovieList(json);
  }

  /// The detail endpoint returns full genre objects, which the list
  /// endpoints do not.
  Future<Movie> fetchMovieDetail(int id) async {
    final json = await _get(_uri('/movie/$id'));
    return Movie.fromJson(json);
  }

  /// Releases the underlying HTTP connections.
  void dispose() => _client.close();

  /// Builds a TMDB URL and injects the key + language automatically.
  Uri _uri(String path, [Map<String, Object?>? query]) {
    final params = <String, String>{
      'api_key': AppConstants.tmdbApiKey,
      'language': 'en-US',
    };
    query?.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });
    return Uri.parse('${AppConstants.tmdbBaseUrl}$path')
        .replace(queryParameters: params);
  }

  /// Performs a GET, validates the response and returns decoded JSON.
  Future<Map<String, dynamic>> _get(Uri uri) async {
    if (!_hasApiKey) {
      throw const ApiException(
        'TMDB API key is missing. Run the app with '
        '--dart-define=TMDB_API_KEY=your_key.',
      );
    }

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'TMDB request failed (${response.statusCode}). Please try again.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Unexpected response from TMDB.');
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'The request timed out. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No internet connection. Please check your network.',
      );
    } on FormatException {
      throw const ApiException('TMDB returned malformed data.');
    } catch (_) {
      throw const ApiException('Something went wrong while loading movies.');
    }
  }

  List<Movie> _parseMovieList(Map<String, dynamic> json) {
    final results = json['results'];
    if (results is! List) return const [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();
  }

  bool get _hasApiKey {
    final key = AppConstants.tmdbApiKey.trim();
    return key.isNotEmpty && key != AppConstants.apiKeyPlaceholder;
  }
}
