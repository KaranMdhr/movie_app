import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../models/movie.dart';

/// Poster tile used by the home grid (and later the favorites grid).
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.isFavorite,
    this.onFavoriteTap,
  });

  final Movie movie;
  final VoidCallback? onTap;

  /// When [onFavoriteTap] is provided, a heart button is shown on the poster.
  final bool? isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Poster(movie: movie),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _RatingBadge(rating: movie.ratingLabel),
                  ),
                  if (onFavoriteTap != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _FavoriteButton(
                        isFavorite: isFavorite ?? false,
                        onPressed: onFavoriteTap!,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    movie.releaseYear ?? '—',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final url = movie.posterUrl;
    if (url == null) return const _PosterFallback();

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, _) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      errorWidget: (_, _, _) => const _PosterFallback(),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.movie_outlined,
        size: 40,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        visualDensity: VisualDensity.compact,
        iconSize: 20,
        color: isFavorite ? Colors.redAccent : Colors.white,
        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
        onPressed: onPressed,
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
            const SizedBox(width: 3),
            Text(
              rating,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
