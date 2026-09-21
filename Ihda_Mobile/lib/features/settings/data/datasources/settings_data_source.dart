import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../prayer_times/domain/entities/prayer.dart';
import '../../domain/entities/app_settings.dart';

/// Settings are genuinely local (device preferences), so unlike the other
/// features this data source isn't split into mock/API variants - it
/// always reads/writes shared_preferences, mock mode or not.
class SettingsDataSource {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final methodName = prefs.getString(AppConstants.prefsKeyCalculationMethod);
    final method = CalculationMethod.values.firstWhere(
      (m) => m.name == methodName,
      orElse: () => CalculationMethod.mwl,
    );
    return AppSettings(
      calculationMethod: method,
      languageCode: prefs.getString(AppConstants.prefsKeyLanguage) ?? 'en',
      region: prefs.getString(AppConstants.prefsKeyRegion) ?? 'Uzbekistan',
      notificationsEnabled:
          prefs.getBool(AppConstants.prefsKeyNotificationsEnabled) ?? true,
      updatesEnabled: prefs.getBool(AppConstants.prefsKeyUpdatesEnabled) ?? false,
      darkMode: prefs.getBool(AppConstants.prefsKeyDarkMode) ?? false,
      mutedPrayers: (prefs.getStringList(AppConstants.prefsKeyPerPrayerNotifications) ?? [])
          .map((name) => PrayerType.values.firstWhere((t) => t.name == name))
          .toSet(),
      domain: prefs.getString(AppConstants.prefsKeyDomain),
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsKeyCalculationMethod, settings.calculationMethod.name);
    await prefs.setString(AppConstants.prefsKeyLanguage, settings.languageCode);
    await prefs.setString(AppConstants.prefsKeyRegion, settings.region);
    await prefs.setBool(AppConstants.prefsKeyNotificationsEnabled, settings.notificationsEnabled);
    await prefs.setBool(AppConstants.prefsKeyUpdatesEnabled, settings.updatesEnabled);
    await prefs.setBool(AppConstants.prefsKeyDarkMode, settings.darkMode);
    if (settings.domain != null) {
      await prefs.setString(AppConstants.prefsKeyDomain, settings.domain!);
    }
    await prefs.setStringList(
      AppConstants.prefsKeyPerPrayerNotifications,
      settings.mutedPrayers.map((t) => t.name).toList(),
    );
  }
}
