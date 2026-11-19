import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';

/// Resolves TMDB credentials from, in order:
///
/// 1. `config.json` served next to the web app (runtime; no rebuild needed)
/// 2. `--dart-define` values from [AppConstants]
///
/// Runtime loading only applies on web. Mobile and desktop builds use the
/// compile-time values.
class AppConfig {
  AppConfig._();

  static String _apiKey = AppConstants.tmdbApiKey.trim();
  static String _accessToken = AppConstants.tmdbAccessToken.trim();
  static bool _loaded = false;

  /// v4 Bearer token. Also accepts a v4 token accidentally pasted into the
  /// `TMDB_API_KEY` field (they start with `eyJ`).
  static String get accessToken {
    if (_accessToken.isNotEmpty) return _accessToken;
    if (_apiKey.startsWith('eyJ')) return _apiKey;
    return '';
  }

  /// v3 API key, or an empty string when not configured.
  static String get apiKey {
    if (_apiKey.startsWith('eyJ')) return '';
    if (_isPlaceholder(_apiKey)) return '';
    return _apiKey;
  }

  static bool get hasCredentials => apiKey.isNotEmpty || accessToken.isNotEmpty;

  /// Fetches `config.json` from the web root on first launch.
  ///
  /// Failure is non-fatal: the app then relies on dart-define values and
  /// shows the normal "credentials missing" message if none exist.
  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    if (!kIsWeb) return;

    try {
      final uri = Uri.base.resolve('config.json');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;

      final key = decoded['TMDB_API_KEY'];
      if (key is String && key.trim().isNotEmpty) {
        _apiKey = key.trim();
      }

      final token = decoded['TMDB_ACCESS_TOKEN'];
      if (token is String && token.trim().isNotEmpty) {
        _accessToken = token.trim();
      }
    } catch (_) {
      // Optional file: keep the compile-time fallback.
    }
  }

  static bool _isPlaceholder(String value) {
    return value.isEmpty || value == AppConstants.apiKeyPlaceholder;
  }
}
