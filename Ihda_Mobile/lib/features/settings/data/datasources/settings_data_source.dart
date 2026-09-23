import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../prayer_times/domain/entities/prayer.dart';
import '../../domain/entities/app_settings.dart';

class SettingsDataSource {
  Future<AppSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodName = prefs.getString(AppConstants.prefsKeyCalculationMethod);
      final method = CalculationMethod.values.firstWhere(
        (m) => m.name == methodName,
        orElse: () => CalculationMethod.mwl,
      );
      final asrName = prefs.getString(AppConstants.prefsKeyAsrCalculation);
      final asr = AsrCalculation.values.firstWhere(
        (a) => a.name == asrName,
        orElse: () => AsrCalculation.hanafi,
      );
      final fontName = prefs.getString('font_size');
      final fontSize = AppFontSize.values.firstWhere(
        (f) => f.name == fontName,
        orElse: () => AppFontSize.medium,
      );
      return AppSettings(
        calculationMethod: method,
        asrCalculation: asr,
        languageCode: prefs.getString(AppConstants.prefsKeyLanguage) ?? 'uz',
        region: prefs.getString(AppConstants.prefsKeyRegion) ?? 'Toshkent shahri',
        notificationsEnabled:
            prefs.getBool(AppConstants.prefsKeyNotificationsEnabled) ?? true,
        updatesEnabled: prefs.getBool(AppConstants.prefsKeyUpdatesEnabled) ?? false,
        darkMode: prefs.getBool(AppConstants.prefsKeyDarkMode) ?? false,
        mutedPrayers: (prefs.getStringList(AppConstants.prefsKeyPerPrayerNotifications) ?? [])
            .map((name) => PrayerType.values.firstWhere((t) => t.name == name))
            .toSet(),
        domain: prefs.getString(AppConstants.prefsKeyDomain) ?? 'ihda.uz',
        fontSize: fontSize,
        fontFamily: prefs.getString('font_family') ?? 'Roboto',
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefsKeyCalculationMethod, settings.calculationMethod.name);
      await prefs.setString(AppConstants.prefsKeyAsrCalculation, settings.asrCalculation.name);
      await prefs.setString(AppConstants.prefsKeyLanguage, settings.languageCode);
      await prefs.setString(AppConstants.prefsKeyRegion, settings.region);
      await prefs.setBool(AppConstants.prefsKeyNotificationsEnabled, settings.notificationsEnabled);
      await prefs.setBool(AppConstants.prefsKeyUpdatesEnabled, settings.updatesEnabled);
      await prefs.setBool(AppConstants.prefsKeyDarkMode, settings.darkMode);
      await prefs.setString(AppConstants.prefsKeyDomain, settings.domain);
      await prefs.setString('font_size', settings.fontSize.name);
      await prefs.setString('font_family', settings.fontFamily);
      await prefs.setStringList(
        AppConstants.prefsKeyPerPrayerNotifications,
        settings.mutedPrayers.map((t) => t.name).toList(),
      );
    } catch (_) {}
  }
}
