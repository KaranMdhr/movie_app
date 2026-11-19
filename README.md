# Movie Discovery

A Flutter movie discovery app powered by [The Movie Database (TMDB) API](https://www.themoviedb.org/documentation/api). Browse trending movies, search by title, view full details, and save favorites locally.

> This product uses the TMDB API but is not endorsed or certified by TMDB.

## Features

- **Trending home** — responsive poster grid with title, release year, and rating.
- **Search** — debounced title search with stale-request protection.
- **Movie details** — backdrop, poster, overview, rating, release date, and genres.
- **Favorites** — save/remove movies locally and browse them on a dedicated screen.
- **Complete states** — loading, error with retry, and empty states on every screen.
- **Theme** — light/dark toggle persisted across restarts.
- **Pull to refresh** — refresh trending movies or retry after an error.

## Tech stack

| Concern | Package / approach |
| --- | --- |
| Framework | Flutter (stable) + Dart, null safety |
| State management | `provider` (`ChangeNotifier`) |
| Networking | `http` |
| Images | `cached_network_image` |
| Navigation | `go_router` |
| Local storage | `shared_preferences` |
| Design | Material 3, single seed color, shared theme |

## Screenshots

<!-- Replace with real screenshots after your first run. -->

| Home | Search | Details | Favorites |
| --- | --- | --- | --- |
| _add image_ | _add image_ | _add image_ | _add image_ |

## Getting started

### Prerequisites

- Flutter 3.50+ (Dart 3.14+)
- A free TMDB account and an **API Key (v3 auth)** from
  [themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure the API key

TMDB accepts either a **v3 API Key** or a **v4 Read Access Token** (Bearer).
Pick one of the options below.

#### Option A — Web, no flags (recommended here)

Create `web/config.json` (git-ignored):

```json
{
  "TMDB_API_KEY": "your_v3_api_key_here"
}
```

The app fetches this file at startup, so a plain `flutter run -d chrome` is
enough. You can use `"TMDB_ACCESS_TOKEN": "your_v4_token"` instead if you have
a v4 Read Access Token.

#### Option B — Compile-time (all platforms)

Create `config.json` in the project root (git-ignored):

```json
{
  "TMDB_API_KEY": "your_v3_api_key_here"
}
```

Run the app with that file:

```bash
flutter run -d chrome --dart-define-from-file=config.json
```

Or pass the key directly:

```bash
flutter run -d chrome --dart-define=TMDB_API_KEY=your_v3_api_key_here
```

In VS Code, pick the **Movie Discovery (config.json)** launch configuration
(`.vscode/launch.json`) and press `F5`. `.vscode/settings.json` also passes the
file to normal Flutter runs started from the editor.

> Option B values are compile-time: fully restart the app after changing them.
> Option A is read on startup, so a browser refresh is enough.

### 3. Run

```bash
flutter run -d chrome
```

For Option B, add `--dart-define-from-file=config.json` (or use the VS Code
launch configuration). Other devices work too, e.g. `-d windows` or
`-d <device-id>`; those builds use compile-time values.

## Project structure

```text
lib/
  main.dart                  # providers, router, MaterialApp.router
  models/
    movie.dart               # fromJson/toJson + display helpers
  services/
    tmdb_service.dart        # HTTP, endpoints, error mapping
  providers/
    theme_provider.dart      # ThemeMode + persistence
    movie_provider.dart      # trending list
    search_provider.dart     # debounced search + stale guard
    movie_detail_provider.dart
    favorites_provider.dart  # local favorites + persistence
  screens/
    home_screen.dart
    search_screen.dart
    detail_screen.dart
    favorites_screen.dart
  widgets/
    movie_card.dart
    movie_grid.dart
    state_views.dart         # LoadingView / ErrorView / EmptyView
    theme_toggle_button.dart
  utils/
    app_config.dart          # runtime config.json + dart-define fallback
    constants.dart           # API URLs + key injection
    theme.dart               # light/dark ThemeData
```

## Architecture notes

- `TmdbService` is the only place that knows URLs, status codes, and JSON. It throws a UI-safe `ApiException`.
- On web, `AppConfig` reads `web/config.json` at startup; compile-time
  `--dart-define` values are the fallback and the only option on other platforms.
- Providers own screen state; widgets only render and call methods.
- `SearchProvider` cancels the debounce timer and uses a request id to ignore stale responses.
- Favorites are stored as JSON snapshots of `Movie`, so the grid renders offline. Toggling waits for the initial restore to avoid overwriting saved data.
- Theme mode is stored under `theme_mode` in `shared_preferences`.
- Loading, error, and empty states are shared widgets, so all screens behave consistently.

## Limitations

- The TMDB key is used client-side and is visible in the built app. With
  Option A it is served publicly at `/config.json`. For a production app,
  proxy requests through a backend so the key stays private.
- Favorites store a snapshot of movie data; changes made on TMDB are not synced.
- No pagination or infinite scroll (not part of the project scope).

## License

Personal portfolio project. Movie data and images are provided by TMDB.
