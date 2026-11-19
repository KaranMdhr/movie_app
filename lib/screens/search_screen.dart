import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../widgets/movie_grid.dart';
import '../widgets/state_views.dart';
import '../widgets/theme_toggle_button.dart';

/// Search screen with a debounced text field.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<SearchProvider>().clear();
    setState(() {}); // refresh the trailing clear icon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: const [ThemeToggleButton(), SizedBox(width: 4)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {}); // update the clear icon as text appears
                context.read<SearchProvider>().onQueryChanged(value);
              },
              onSubmitted: (value) =>
                  context.read<SearchProvider>().submit(value),
              decoration: InputDecoration(
                hintText: 'Search movies by name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: _clear,
                      ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingView(message: 'Searching...');
                }

                if (provider.errorMessage != null) {
                  return ErrorView(
                    message: provider.errorMessage!,
                    onRetry: provider.retry,
                  );
                }

                if (!provider.hasSearched) {
                  return const EmptyView(
                    icon: Icons.search,
                    title: 'Find your next movie',
                    message: 'Start typing a title to search TMDB.',
                  );
                }

                if (provider.results.isEmpty) {
                  return EmptyView(
                    title: 'No movies found',
                    message:
                        'Nothing matched “${provider.query.trim()}”. '
                        'Try another title.',
                  );
                }

                return MovieGrid(
                  movies: provider.results,
                  onMovieTap: (movie) =>
                      context.push('/movie/${movie.id}', extra: movie),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
