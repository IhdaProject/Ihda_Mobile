import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    },
  );

  static ThemeData getTheme({
    required bool isDark,
    required String fontFamily,
    required double fontScale,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: isDark ? const Color(0xFF142C26) : AppColors.surface,
      onSurface: isDark ? Colors.white : AppColors.textPrimary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      error: AppColors.error,
    );

    final rawTextTheme = TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: isDark ? Colors.white : AppColors.textPrimary),
      displayMedium: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.textPrimary),
      titleLarge: AppTextStyles.title.copyWith(color: isDark ? Colors.white : AppColors.textPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimary),
      bodyMedium: AppTextStyles.bodyMuted.copyWith(color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary),
      labelMedium: AppTextStyles.caption.copyWith(color: isDark ? Colors.white.withOpacity(0.6) : AppColors.textSecondary),
    );

    TextTheme configuredTextTheme;
    String actualFontFamily = fontFamily;
    try {
      configuredTextTheme = GoogleFonts.getTextTheme(fontFamily, rawTextTheme);
      actualFontFamily = GoogleFonts.getFont(fontFamily).fontFamily ?? fontFamily;
    } catch (_) {
      configuredTextTheme = rawTextTheme.apply(fontFamily: fontFamily);
    }

    final scaledIconSize = 24.0 * fontScale;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0C1F1A) : AppColors.background,
      fontFamily: actualFontFamily,
      textTheme: configuredTextTheme,
      iconTheme: IconThemeData(
        size: scaledIconSize,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      primaryIconTheme: IconThemeData(
        size: scaledIconSize,
        color: AppColors.primary,
      ),
      pageTransitionsTheme: _pageTransitionsTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        iconTheme: IconThemeData(size: scaledIconSize),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF16302A) : AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDark ? AppRadius.lg : 24),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF16302A) : AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        elevation: isDark ? 0 : 10,
        height: 72,
        labelBehavior: isDark
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? AppColors.primary
              : (isDark ? Colors.white70 : AppColors.textSecondary);
          return IconThemeData(color: color, size: 24.0 * fontScale);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.divider,
        ),
      ),
    );
  }

  static ThemeData get light => getTheme(isDark: false, fontFamily: 'Roboto', fontScale: 1.0);
  static ThemeData get dark => getTheme(isDark: true, fontFamily: 'Roboto', fontScale: 1.0);
}
