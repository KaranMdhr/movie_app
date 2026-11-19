/// App-wide configuration values.
///
/// Nothing in this file should ever be imported by a widget just to read a
/// hardcoded secret: keep keys here, then inject them through services.
class AppConstants {
  AppConstants._();

  /// TMDB API key (v3 auth).
  ///
  /// Never hardcode a real key in committed source. Pass it at run time:
  ///   flutter run -d chrome --dart-define=TMDB_API_KEY=your_key
  /// or put it in the git-ignored `config.json` and run:
  ///   flutter run -d chrome --dart-define-from-file=config.json
  static const String apiKeyPlaceholder = 'PASTE_YOUR_TMDB_API_KEY_HERE';

  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: apiKeyPlaceholder,
  );

  /// Root of the TMDB REST API (v3).
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

  /// Poster images are ~500px wide, which is plenty for grid tiles.
  static const String posterBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Backdrop images are ~780px wide, used on the detail screen.
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/w780';
}
