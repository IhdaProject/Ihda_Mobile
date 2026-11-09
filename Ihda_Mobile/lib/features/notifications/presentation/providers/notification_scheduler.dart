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

// Memory tracking set to prevent duplicate immediate triggers within the same minute
final Set<String> _triggeredInAppKeys = {};

/// Schedules offline system AlarmClock notifications for today and tomorrow.
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

      for (final prayer in day.prayers) {
        if (!prayer.type.isNotifiable) continue;
        if (settings.mutedPrayers.contains(prayer.type)) continue;

        final configId = _getPrayerConfigId(prayer.type);
        final config = detailedSettings.mainPrayers.firstWhere(
          (c) => c.id == configId,
          orElse: () => PrayerNotificationConfig(id: configId, name: prayer.type.label, enabled: true),
        );

        if (!config.enabled) continue;

        var scheduledTime = prayer.time.add(Duration(minutes: config.offsetMinutes));
        var notificationId = (prayer.type.index + 1) * 10;

        // If today's time has already passed, schedule for tomorrow
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
          notificationId = (prayer.type.index + 1) * 10 + 100;
        }

        final bodyText = config.offsetMinutes == 0
            ? 'Hozir ${prayer.type.label} namozi vaqti kirdi.'
            : (config.offsetMinutes < 0
                ? '${prayer.type.label} namoziga ${config.offsetMinutes.abs()} daqiqa qoldi.'
                : '${prayer.type.label} namozidan ${config.offsetMinutes} daqiqa o\'tdi.');

        dataSource.schedulePrayerNotification(
          id: notificationId,
          title: '${prayer.type.label} namozi vaqti bo\'ldi',
          body: bodyText,
          scheduledTime: scheduledTime,
          soundType: config.sound,
          customAudioPath: config.customAudioName,
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
        if (!prayer.type.isNotifiable) continue;
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

            final bodyText = config.offsetMinutes == 0
                ? 'Hozir ${prayer.type.label} namozi vaqti kirdi.'
                : (config.offsetMinutes < 0
                    ? '${prayer.type.label} namoziga ${config.offsetMinutes.abs()} daqiqa qoldi.'
                    : '${prayer.type.label} namozidan ${config.offsetMinutes} daqiqa o\'tdi.');

            dataSource.showImmediateTestNotification(
              title: '${prayer.type.label} namozi vaqti bo\'ldi',
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
