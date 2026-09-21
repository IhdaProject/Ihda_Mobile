import '../../../prayer_times/domain/entities/prayer.dart';

class AppSettings {
  final CalculationMethod calculationMethod;
  final String languageCode; // 'en', 'uz', 'ru' ...
  final String region;
  final bool notificationsEnabled;
  final bool updatesEnabled;
  final bool darkMode;
  final Set<PrayerType> mutedPrayers;
  final String? domain;

  const AppSettings({
    this.calculationMethod = CalculationMethod.mwl,
    this.languageCode = 'en',
    this.region = 'Uzbekistan',
    this.notificationsEnabled = true,
    this.updatesEnabled = false,
    this.darkMode = false,
    this.mutedPrayers = const {},
    this.domain,
  });

  AppSettings copyWith({
    CalculationMethod? calculationMethod,
    String? languageCode,
    String? region,
    bool? notificationsEnabled,
    bool? updatesEnabled,
    bool? darkMode,
    Set<PrayerType>? mutedPrayers,
    String? domain,
  }) {
    return AppSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      languageCode: languageCode ?? this.languageCode,
      region: region ?? this.region,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      updatesEnabled: updatesEnabled ?? this.updatesEnabled,
      darkMode: darkMode ?? this.darkMode,
      mutedPrayers: mutedPrayers ?? this.mutedPrayers,
      domain: domain ?? this.domain,
    );
  }
}
