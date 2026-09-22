import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../prayer_times/domain/entities/prayer.dart';
import '../../data/datasources/settings_data_source.dart';
import '../../domain/entities/app_settings.dart';

final settingsDataSourceProvider = Provider((ref) => SettingsDataSource());

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.read(settingsDataSourceProvider).load();
  }

  Future<void> _persist(AppSettings updated) async {
    state = AsyncData(updated);
    await ref.read(settingsDataSourceProvider).save(updated);
  }

  Future<void> setCalculationMethod(CalculationMethod method) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(calculationMethod: method));
  }

  Future<void> setAsrCalculation(AsrCalculation asr) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(asrCalculation: asr));
  }

  Future<void> setLanguage(String code) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(languageCode: code));
  }

  Future<void> setRegion(String region) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(region: region));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setUpdatesEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(updatesEnabled: enabled));
  }

  Future<void> setDarkMode(bool enabled) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(darkMode: enabled));
  }

  Future<void> setDomain(String domain) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(domain: domain));
  }

  Future<void> setFontSize(AppFontSize fontSize) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(fontSize: fontSize));
  }

  Future<void> setFontFamily(String fontFamily) async {
    final current = state.valueOrNull ?? const AppSettings();
    await _persist(current.copyWith(fontFamily: fontFamily));
  }

  Future<void> togglePrayerMuted(PrayerType type) async {
    final current = state.valueOrNull ?? const AppSettings();
    final muted = {...current.mutedPrayers};
    if (!muted.add(type)) muted.remove(type);
    await _persist(current.copyWith(mutedPrayers: muted));
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);
