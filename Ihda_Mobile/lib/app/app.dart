import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/providers/settings_providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'main_shell.dart';
import '../features/settings/presentation/screens/domain_selection_screen.dart';

class NamazTimingApp extends ConsumerWidget {
  const NamazTimingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (e, _) => MaterialApp(home: Scaffold(body: Center(child: Text(e.toString())))),
      data: (settings) {
        final darkMode = settings.darkMode;
        final hasDomain = settings.domain != null && settings.domain!.isNotEmpty;

        return MaterialApp(
          title: 'Namaz Timing',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          home: hasDomain ? const MainShell() : const DomainSelectionScreen(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
