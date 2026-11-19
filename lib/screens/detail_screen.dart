import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/favorites_provider.dart';
import '../providers/movie_detail_provider.dart';
import '../widgets/state_views.dart';
import '../widgets/theme_toggle_button.dart';

/// Detail screen: backdrop, poster, title, rating, release date, genres
/// and overview for one movie.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load after the first frame; the passed-in movie (if any) is shown
    // immediately while the full detail request runs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MovieDetailProvider>().load();
    });
  }

  Future<void> _toggleFavorite(Movie movie) async {
    final favorites = context.read<FavoritesProvider>();
    final wasFavorite = favorites.isFavorite(movie.id);
    await favorites.toggle(movie);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasFavorite ? 'Removed from favorites' : 'Added to favorites',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieDetailProvider>();
    final movie = provider.movie;
    final isFavorite =
        movie != null &&
        context.watch<FavoritesProvider>().isFavorite(movie.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(movie?.title ?? 'Movie details'),
        actions: [
          if (movie != null)
            IconButton(
              tooltip: isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () => _toggleFavorite(movie),
            ),
          const ThemeToggleButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: movie == null
          ? (provider.hasLoaded && !provider.isLoading
                ? ErrorView(
                    message: provider.errorMessage ?? 'Movie not found.',
                    onRetry: provider.retry,
                  )
                : const LoadingView(message: 'Loading movie details...'))
          : _DetailContent(movie: movie),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backdropUrl = movie.backdropUrl;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (backdropUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: backdropUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (_, _, _) =>
                    _ImageFallback(icon: Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 165,
                child: _Poster(movie: movie),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    text: '${movie.ratingLabel} / 10',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: movie.formattedReleaseDate,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (movie.genres.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final genre in movie.genres)
                Chip(label: Text(genre), visualDensity: VisualDensity.compact),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.overview.trim().isEmpty
              ? 'No overview available for this movie.'
              : movie.overview,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
        ),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final url = movie.posterUrl;
    if (url == null) {
      return const _ImageFallback(icon: Icons.movie_outlined);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, _) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      errorWidget: (_, _, _) =>
          const _ImageFallback(icon: Icons.movie_outlined),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.iconColor});

  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
