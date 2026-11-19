import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// App-bar action that flips the theme and persists the choice.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => context.read<ThemeProvider>().toggleTheme(isDark),
    );
  }
}
