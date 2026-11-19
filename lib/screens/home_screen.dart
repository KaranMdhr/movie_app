import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_grid.dart';
import '../widgets/theme_toggle_button.dart';

/// Home screen: a responsive grid of trending movies.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load after the first frame so notifyListeners() never runs during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MovieProvider>().loadTrending();
    });
  }

  Future<void> _refresh() {
    // Keep the current grid on screen while refreshing.
    return context.read<MovieProvider>().loadTrending(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    final favoritesCount = context.watch<FavoritesProvider>().favorites.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending this week'),
        actions: [
          IconButton(
            tooltip: 'Search movies',
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            tooltip: 'Favorites',
            icon: Badge(
              isLabelVisible: favoritesCount > 0,
              label: Text('$favoritesCount'),
              child: const Icon(Icons.favorite_border),
            ),
            onPressed: () => context.push('/favorites'),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Consumer<MovieProvider>(
          builder: (context, provider, _) {
            if (!provider.hasLoaded ||
                (provider.isLoading && !provider.hasMovies)) {
              return const _LoadingState();
            }

            if (provider.errorMessage != null && !provider.hasMovies) {
              return _ErrorState(
                message: provider.errorMessage!,
                onRetry: provider.retry,
              );
            }

            if (!provider.hasMovies) {
              return const _EmptyState();
            }

            return MovieGrid(
              movies: provider.movies,
              physics: const AlwaysScrollableScrollPhysics(),
              onMovieTap: (movie) =>
                  context.push('/movie/${movie.id}', extra: movie),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading trending movies...'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
              Icons.cloud_off_outlined,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 56,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No trending movies right now', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Pull down to refresh.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
