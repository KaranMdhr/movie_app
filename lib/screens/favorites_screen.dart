import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../widgets/movie_grid.dart';
import '../widgets/state_views.dart';
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
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, FavoritesProvider provider) {
    if (provider.isLoading) {
      return const LoadingView(message: 'Loading favorites...');
    }

    if (provider.errorMessage != null && provider.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.retry,
      );
    }

    if (provider.isEmpty) {
      return const EmptyView(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message: 'Tap the heart on a movie to save it here.',
      );
    }

    return MovieGrid(
      movies: provider.favorites,
      onMovieTap: (movie) => context.push('/movie/${movie.id}', extra: movie),
      isFavorite: (_) => true,
      onFavoriteTap: (movie) =>
          context.read<FavoritesProvider>().remove(movie.id),
    );
  }
}
