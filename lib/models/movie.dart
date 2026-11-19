import '../utils/constants.dart';

/// A movie as returned by TMDB.
///
/// TMDB sends slightly different payloads depending on the endpoint:
/// list endpoints (`/trending`, `/search`) only include `genre_ids`,
/// while `/movie/{id}` includes full `genres` objects. [fromJson] accepts
/// both so the same model works everywhere.
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.genreIds = const [],
    this.genres = const [],
  });

  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;

  /// Raw TMDB value like `2024-07-19`; keep it raw and format on demand.
  final String? releaseDate;

  /// IDs work on list endpoints where genre names are not returned.
  final List<int> genreIds;

  /// Human-readable genre names, available on the detail endpoint.
  final List<String> genres;

  factory Movie.fromJson(Map<String, dynamic> json) {
    // TMDB occasionally returns `name` instead of `title` for some items,
    // so fall back defensively and never produce a null title.
    final rawTitle = json['title'] ?? json['name'];

    final rawGenres = json['genres'] as List<dynamic>? ?? const [];

    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: rawTitle is String && rawTitle.isNotEmpty ? rawTitle : 'Untitled',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      posterPath: _nonEmpty(json['poster_path']),
      backdropPath: _nonEmpty(json['backdrop_path']),
      releaseDate: _nonEmpty(json['release_date']),
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((id) => id.toInt())
          .toList(),
      // Detail responses give maps; locally saved favorites give strings.
      genres: rawGenres
          .map((genre) {
            if (genre is String) return genre;
            if (genre is Map<String, dynamic>) {
              return genre['name'] as String? ?? '';
            }
            return '';
          })
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }

  /// Used to persist favorites locally with shared_preferences.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'overview': overview,
    'vote_average': voteAverage,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'release_date': releaseDate,
    'genre_ids': genreIds,
    'genres': genres,
  };

  /// Full poster URL, or null so widgets can show a placeholder.
  String? get posterUrl {
    if (posterPath == null) return null;
    return '${AppConstants.posterBaseUrl}$posterPath';
  }

  String? get backdropUrl {
    if (backdropPath == null) return null;
    return '${AppConstants.backdropBaseUrl}$backdropPath';
  }

  /// Short rating label such as `7.4`.
  String get ratingLabel => voteAverage.toStringAsFixed(1);

  /// Release year such as `2024`, or null when TMDB has no date.
  String? get releaseYear {
    if (releaseDate == null || releaseDate!.length < 4) return null;
    return releaseDate!.substring(0, 4);
  }

  /// Friendly date such as `Jul 19, 2024`. Done manually to avoid adding
  /// the `intl` package for a single label.
  String get formattedReleaseDate {
    final parsed = DateTime.tryParse(releaseDate ?? '');
    if (parsed == null) return 'Release date unknown';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  /// Shared by `poster_path`, `backdrop_path` and `release_date`, which TMDB
  /// normally sends as `null` but can also send as an empty string.
  static String? _nonEmpty(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }
}
