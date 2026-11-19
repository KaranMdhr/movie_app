import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../widgets/movie_grid.dart';
import '../widgets/theme_toggle_button.dart';

/// Shows locally saved favorites and lets the user remove them.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: const [ThemeToggleButton(), SizedBox(width: 4)],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.favorites.isEmpty
              ? const _EmptyFavorites()
              : MovieGrid(
                  movies: provider.favorites,
                  onMovieTap: (movie) =>
                      context.push('/movie/${movie.id}', extra: movie),
                  isFavorite: (_) => true,
                  onFavoriteTap: (movie) =>
                      context.read<FavoritesProvider>().remove(movie.id),
                ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text('No favorites yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Tap the heart on a movie to save it here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
