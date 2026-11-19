import 'package:material_ui/material_ui.dart';

import '../models/movie.dart';
import 'movie_card.dart';

/// Responsive poster grid shared by Home, Search and Favorites.
class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    this.onMovieTap,
    this.physics,
    this.padding = const EdgeInsets.all(16),
    this.isFavorite,
    this.onFavoriteTap,
  });

  final List<Movie> movies;
  final ValueChanged<Movie>? onMovieTap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  /// Optional favorite state + toggle, used by the Favorites screen.
  final bool Function(Movie movie)? isFavorite;
  final ValueChanged<Movie>? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: physics,
      padding: padding,
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        // Taller than wide so a 2:3 poster plus two text lines fits.
        childAspectRatio: 0.52,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(
          movie: movie,
          onTap: onMovieTap == null ? null : () => onMovieTap!(movie),
          isFavorite: isFavorite?.call(movie),
          onFavoriteTap: onFavoriteTap == null
              ? null
              : () => onFavoriteTap!(movie),
        );
      },
    );
  }
}
