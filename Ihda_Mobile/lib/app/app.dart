import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import 'main_shell.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class NamazTimingApp extends ConsumerWidget {
  const NamazTimingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text(e.toString()))),
      ),
      data: (settings) {
        final darkMode = settings.darkMode;
        final fontScale = settings.fontSize.scale;

        final lightTheme = AppTheme.getTheme(
          isDark: false,
          fontFamily: settings.fontFamily,
          fontScale: fontScale,
        );
        final darkTheme = AppTheme.getTheme(
          isDark: true,
          fontFamily: settings.fontFamily,
          fontScale: fontScale,
        );

        return MaterialApp(
          title: 'Ihda Mobile',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(fontScale),
              ),
              child: IconTheme(
                data: IconTheme.of(context).copyWith(
                  size: 24.0 * fontScale,
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: const MainShell(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
