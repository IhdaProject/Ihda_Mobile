import '../../../prayer_times/domain/entities/prayer.dart';

enum AsrCalculation { standard, hanafi }

extension AsrCalculationX on AsrCalculation {
  String get label {
    switch (this) {
      case AsrCalculation.standard:
        return "Standart (Shofi'iy, Molikiy, Hanbaliy)";
      case AsrCalculation.hanafi:
        return 'Hanafiy';
    }
  }
}

enum AppFontSize { small, medium, large, extraLarge }

extension AppFontSizeX on AppFontSize {
  double get scale {
    switch (this) {
      case AppFontSize.small:
        return 0.85;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.15;
      case AppFontSize.extraLarge:
        return 1.30;
    }
  }

  String get label {
    switch (this) {
      case AppFontSize.small:
        return 'Kichik (85%)';
      case AppFontSize.medium:
        return 'O\'rtacha (100%)';
      case AppFontSize.large:
        return 'Katta (115%)';
      case AppFontSize.extraLarge:
        return 'Juda katta (130%)';
    }
  }
}

class AppSettings {
  final CalculationMethod calculationMethod;
  final AsrCalculation asrCalculation;
  final String languageCode; // 'uz', 'ru', 'en' ...
  final String region;
  final bool notificationsEnabled;
  final bool updatesEnabled;
  final bool darkMode;
  final Set<PrayerType> mutedPrayers;
  final String domain;
  final AppFontSize fontSize;
  final String fontFamily;

  const AppSettings({
    this.calculationMethod = CalculationMethod.mwl,
    this.asrCalculation = AsrCalculation.hanafi,
    this.languageCode = 'uz',
    this.region = 'Toshkent shahri',
    this.notificationsEnabled = true,
    this.updatesEnabled = false,
    this.darkMode = false,
    this.mutedPrayers = const {},
    this.domain = 'ihda.uz',
    this.fontSize = AppFontSize.medium,
    this.fontFamily = 'Roboto',
  });

  AppSettings copyWith({
    CalculationMethod? calculationMethod,
    AsrCalculation? asrCalculation,
    String? languageCode,
    String? region,
    bool? notificationsEnabled,
    bool? updatesEnabled,
    bool? darkMode,
    Set<PrayerType>? mutedPrayers,
    String? domain,
    AppFontSize? fontSize,
    String? fontFamily,
  }) {
    return AppSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      asrCalculation: asrCalculation ?? this.asrCalculation,
      languageCode: languageCode ?? this.languageCode,
      region: region ?? this.region,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      updatesEnabled: updatesEnabled ?? this.updatesEnabled,
      darkMode: darkMode ?? this.darkMode,
      mutedPrayers: mutedPrayers ?? this.mutedPrayers,
      domain: domain ?? this.domain,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
