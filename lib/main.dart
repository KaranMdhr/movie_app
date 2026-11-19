import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'models/movie.dart';
import 'providers/favorites_provider.dart';
import 'providers/movie_detail_provider.dart';
import 'providers/movie_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'services/tmdb_service.dart';
import 'utils/app_config.dart';
import 'utils/theme.dart';

/// App routes.
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final movieId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final extra = state.extra;
        final initialMovie = extra is Movie ? extra : null;

        // Each detail page gets its own provider and HTTP client.
        return ChangeNotifierProvider(
          create: (_) => MovieDetailProvider(
            TmdbService(),
            movieId,
            initialMovie: initialMovie,
          ),
          child: const DetailScreen(),
        );
      },
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On web this reads web/config.json at runtime, so a plain
  // `flutter run -d chrome` works without dart-define flags.
  await AppConfig.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider(TmdbService())),
        ChangeNotifierProvider(create: (_) => SearchProvider(TmdbService())),
      ],
      child: const MovieDiscoveryApp(),
    ),
  );
}

class MovieDiscoveryApp extends StatelessWidget {
  const MovieDiscoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds MaterialApp whenever the theme mode changes.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: 'Movie Discovery',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}
