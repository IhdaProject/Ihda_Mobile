import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../prayer_times/domain/entities/prayer.dart';
import '../../../prayer_times/presentation/providers/prayer_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/notification_settings.dart';
import 'notification_providers.dart';

String _getPrayerConfigId(PrayerType type) {
  switch (type) {
    case PrayerType.fajr:
      return 'fajr';
    case PrayerType.sunrise:
      return 'sunrise';
    case PrayerType.dhuhr:
      return 'dhuhr';
    case PrayerType.asr:
      return 'asr';
    case PrayerType.maghrib:
      return 'maghrib';
    case PrayerType.isha:
      return 'isha';
  }
}

final Set<String> _triggeredInAppKeys = {};

/// Schedules 20+ offline system AlarmClock notifications for today and tomorrow.
/// Does NOT watch clockTickProvider so system alarms stay permanently registered in AlarmManager!
final notificationSchedulerProvider = Provider.autoDispose<void>((ref) {
  ref.watch(notificationInitializerProvider);

  final settingsAsync = ref.watch(settingsControllerProvider);
  final detailedSettings = ref.watch(detailedNotificationSettingsProvider);
  final prayerDayAsync = ref.watch(todayPrayerDayProvider);
  final dataSource = ref.watch(notificationDataSourceProvider);

  if (settingsAsync.hasValue && prayerDayAsync.hasValue) {
    final settings = settingsAsync.value!;
    final day = prayerDayAsync.value!;

    dataSource.cancelAll().then((_) {
      if (!settings.notificationsEnabled || !detailedSettings.globalEnabled) return;

      final now = DateTime.now();

      // 1. Schedule all 6 main prayer events (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
      for (final prayer in day.prayers) {
        if (settings.mutedPrayers.contains(prayer.type)) continue;

        final configId = _getPrayerConfigId(prayer.type);
        final config = detailedSettings.mainPrayers.firstWhere(
          (c) => c.id == configId,
          orElse: () => PrayerNotificationConfig(id: configId, name: prayer.type.label, enabled: true),
        );

        if (!config.enabled) continue;

        var scheduledTime = prayer.time.add(Duration(minutes: config.offsetMinutes));
        var notificationId = (prayer.type.index + 1) * 10;

        // If today's time has already passed, schedule for tomorrow!
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
          notificationId = (prayer.type.index + 1) * 10 + 100;
        }

        final titleText = prayer.type == PrayerType.sunrise
            ? 'Quyosh chiqishi (Bomdod chiqishi)'
            : '${prayer.type.label} kirishi (Namoz vaqti)';

        final bodyText = config.offsetMinutes == 0
            ? 'Hozir ${prayer.type.label} vaqti kirdi.'
            : (config.offsetMinutes < 0
                ? '${prayer.type.label} vaqtiga ${config.offsetMinutes.abs()} daqiqa qoldi.'
                : '${prayer.type.label} vaqtidan ${config.offsetMinutes} daqiqa o\'tdi.');

        dataSource.schedulePrayerNotification(
          id: notificationId,
          title: titleText,
          body: bodyText,
          scheduledTime: scheduledTime,
          soundType: config.sound,
          customAudioPath: config.customAudioName,
        );
      }

      // 2. Schedule Nafl Prayer Events (Ishroq, Zuho, Tahajjud)
      final sunrise = day.byType(PrayerType.sunrise);
      final fajrToday = day.byType(PrayerType.fajr);
      final ishaToday = day.byType(PrayerType.isha);

      // A. Ishroq (Sunrise + 15 minutes)
      final ishraqConfig = detailedSettings.naflPrayers.firstWhere(
        (p) => p.id == 'ishraq',
        orElse: () => const PrayerNotificationConfig(id: 'ishraq', name: 'Ishroq', enabled: true),
      );
      if (ishraqConfig.enabled && sunrise != null) {
        var ishraqTime = sunrise.time.add(const Duration(minutes: 15)).add(Duration(minutes: ishraqConfig.offsetMinutes));
        var id = 70;
        if (ishraqTime.isBefore(now)) {
          ishraqTime = ishraqTime.add(const Duration(days: 1));
          id = 170;
        }
        dataSource.schedulePrayerNotification(
          id: id,
          title: 'Ishroq kirishi (Nafl namoz)',
          body: 'Quyosh chiqishidan 15 daqiqa o\'tdi. Ishroq namozini o\'qish vaqti kirdi.',
          scheduledTime: ishraqTime,
          soundType: ishraqConfig.sound,
          customAudioPath: ishraqConfig.customAudioName,
        );
      }

      // B. Zuho / Choshgoh (Sunrise + 30 minutes)
      final duhaConfig = detailedSettings.naflPrayers.firstWhere(
        (p) => p.id == 'duha',
        orElse: () => const PrayerNotificationConfig(id: 'duha', name: 'Zuho', enabled: true),
      );
      if (duhaConfig.enabled && sunrise != null) {
        var duhaTime = sunrise.time.add(const Duration(minutes: 30)).add(Duration(minutes: duhaConfig.offsetMinutes));
        var id = 80;
        if (duhaTime.isBefore(now)) {
          duhaTime = duhaTime.add(const Duration(days: 1));
          id = 180;
        }
        dataSource.schedulePrayerNotification(
          id: id,
          title: 'Zuho kirishi (Choshgoh namozi)',
          body: 'Zuho (Choshgoh) namozini o\'qish vaqti kirdi.',
          scheduledTime: duhaTime,
          soundType: duhaConfig.sound,
          customAudioPath: duhaConfig.customAudioName,
        );
      }

      // C. Tahajjud (After 2/3 of Night between Xufton and Tomorrow's Bomdod)
      final tahajjudConfig = detailedSettings.naflPrayers.firstWhere(
        (p) => p.id == 'tahajjud',
        orElse: () => const PrayerNotificationConfig(id: 'tahajjud', name: 'Tahajjud', enabled: true),
      );
      if (tahajjudConfig.enabled && ishaToday != null && fajrToday != null) {
        final tomorrowFajr = fajrToday.time.add(const Duration(days: 1));
        final nightSecs = tomorrowFajr.difference(ishaToday.time).inSeconds;
        var tahajjudTime = ishaToday.time
            .add(Duration(seconds: (nightSecs * 2 / 3).round()))
            .add(Duration(minutes: tahajjudConfig.offsetMinutes));

        var id = 90;
        if (tahajjudTime.isBefore(now)) {
          tahajjudTime = tahajjudTime.add(const Duration(days: 1));
          id = 190;
        }
        dataSource.schedulePrayerNotification(
          id: id,
          title: 'Tahajjud vaqti kirdi (Kecha namozi)',
          body: 'Kechaning uchdan ikki qismi o\'tdi. Tahajjud namozini o\'qish vaqti kirdi.',
          scheduledTime: tahajjudTime,
          soundType: tahajjudConfig.sound,
          customAudioPath: tahajjudConfig.customAudioName,
        );
      }
    });
  }
});

/// Live in-app ticker that watches clockTickProvider for immediate triggers when app is open in foreground.
final inAppPrayerTickerProvider = Provider.autoDispose<void>((ref) {
  final clockAsync = ref.watch(clockTickProvider);
  final settingsAsync = ref.watch(settingsControllerProvider);
  final detailedSettings = ref.watch(detailedNotificationSettingsProvider);
  final prayerDayAsync = ref.watch(todayPrayerDayProvider);
  final dataSource = ref.watch(notificationDataSourceProvider);

  if (clockAsync.hasValue &&
      settingsAsync.hasValue &&
      prayerDayAsync.hasValue &&
      settingsAsync.value!.notificationsEnabled &&
      detailedSettings.globalEnabled) {

    final now = clockAsync.value!;
    if (now.second == 0) {
      final day = prayerDayAsync.value!;
      final settings = settingsAsync.value!;

      for (final prayer in day.prayers) {
        if (settings.mutedPrayers.contains(prayer.type)) continue;

        final configId = _getPrayerConfigId(prayer.type);
        final config = detailedSettings.mainPrayers.firstWhere(
          (c) => c.id == configId,
          orElse: () => PrayerNotificationConfig(id: configId, name: prayer.type.label, enabled: true),
        );

        if (!config.enabled) continue;

        final targetTime = prayer.time.add(Duration(minutes: config.offsetMinutes));

        if (now.year == targetTime.year &&
            now.month == targetTime.month &&
            now.day == targetTime.day &&
            now.hour == targetTime.hour &&
            now.minute == targetTime.minute) {

          final key = '${configId}_${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}';

          if (!_triggeredInAppKeys.contains(key)) {
            _triggeredInAppKeys.add(key);

            final titleText = prayer.type == PrayerType.sunrise
                ? 'Quyosh chiqishi (Bomdod chiqishi)'
                : '${prayer.type.label} kirishi (Namoz vaqti)';

            final bodyText = config.offsetMinutes == 0
                ? 'Hozir ${prayer.type.label} vaqti kirdi.'
                : (config.offsetMinutes < 0
                    ? '${prayer.type.label} vaqtiga ${config.offsetMinutes.abs()} daqiqa qoldi.'
                    : '${prayer.type.label} vaqtidan ${config.offsetMinutes} daqiqa o\'tdi.');

            dataSource.showImmediateTestNotification(
              title: titleText,
              body: bodyText,
              soundType: config.sound,
              customAudioPath: config.customAudioName,
            );
          }
        }
      }
    }
  }
});
