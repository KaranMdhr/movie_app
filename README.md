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

## Deploying to Vercel

The key is never committed. On Vercel it comes from an environment variable and
is served by a small function (`api/config.js`) at `/config.json`, so the static
Flutter build contains no key.

### GitHub auto-deploy

`vercel.json` runs `scripts/vercel-build.sh`, which installs Flutter stable and
builds `build/web` on Vercel. The first build takes several minutes.

1. In Vercel, open **Project → Settings → Environment Variables** and add
   `TMDB_API_KEY` (or `TMDB_ACCESS_TOKEN`) for Production and Preview.
2. Push to `main` (or click **Redeploy**). Vercel builds and serves the app.

### Local CLI deploy

Useful if you do not want Vercel to build Flutter:

```bash
npm i -g vercel
vercel login
vercel link

vercel env add TMDB_API_KEY production
vercel env add TMDB_API_KEY preview

flutter build web --release
vercel --prod
```

`build/web/config.json` is excluded by `.vercelignore`, so the deployed
`/config.json` is the function rather than your local file. After changing the
Vercel variable, redeploy for the new value to take effect.

### Troubleshooting

- `/config.json` returns `{}`: the current deployment does not see
  `TMDB_API_KEY`. Environment variable changes only apply to **new**
  deployments, so redeploy after adding or editing one.
- Root URL returns 404: the Flutter build did not produce `build/web`. Check
  the Vercel build log for the `flutter build web` step.

## Project structure

```text
api/
  config.js                  # Vercel function: key from env at /config.json
scripts/
  vercel-build.sh            # installs Flutter + builds web on Vercel
vercel.json                  # build/output config + config.json rewrite
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

- The TMDB key is used client-side. On Vercel it is served at `/config.json`
  from an environment variable, so it is not in Git or the static JS, but any
  visitor can still read it in the browser. Hiding it completely requires
  proxying all TMDB requests through a backend.
- Favorites store a snapshot of movie data; changes made on TMDB are not synced.
- No pagination or infinite scroll (not part of the project scope).

## License

Personal portfolio project. Movie data and images are provided by TMDB.
