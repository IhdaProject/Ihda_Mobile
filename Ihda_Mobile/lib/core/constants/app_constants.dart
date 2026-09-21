class AppConstants {
  AppConstants._();

  /// Single place to change the backend base URL.
  /// Safe to leave as-is: the app runs entirely on mock data by default
  /// (see AppEnvironment.dataSourceMode), so this URL is never hit unless
  /// you switch to DataSourceMode.api.
  static const String apiBaseUrl = 'https://api.example.com';

  static const Duration apiTimeout = Duration(seconds: 15);

  static const String prefsKeyCalculationMethod = 'calculation_method';
  static const String prefsKeyLanguage = 'language';
  static const String prefsKeyRegion = 'region';
  static const String prefsKeyNotificationsEnabled = 'notifications_enabled';
  static const String prefsKeyUpdatesEnabled = 'updates_enabled';
  static const String prefsKeyDarkMode = 'dark_mode';
  static const String prefsKeyPerPrayerNotifications = 'per_prayer_notifications';
  static const String prefsKeyThemeMode = 'theme_mode';
  static const String prefsKeyDomain = 'app_domain';

  static const String defaultCityName = 'Tashkent';
  static const String defaultCountryName = 'Uzbekistan';
  static const double defaultLatitude = 41.2995;
  static const double defaultLongitude = 69.2401;
}
