import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_grid.dart';
import '../widgets/state_views.dart';
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
              return const LoadingView(message: 'Loading trending movies...');
            }

            if (provider.errorMessage != null && !provider.hasMovies) {
              return ErrorView(
                message: provider.errorMessage!,
                onRetry: provider.retry,
              );
            }

            if (!provider.hasMovies) {
              return const EmptyView(
                title: 'No trending movies right now',
                message: 'Pull down to refresh.',
              );
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
