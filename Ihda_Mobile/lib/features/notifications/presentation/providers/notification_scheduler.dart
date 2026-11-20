import 'package:intl/intl.dart';
import '../../domain/reminder_time.dart';
import 'package:flutter/foundation.dart';
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
Future<void> _schedulingQueue = Future.value();

/// Schedules rolling multi-day offline alarms (5 days ahead, ~45 alarms).
final notificationSchedulerProvider = FutureProvider<void>((ref) async {
  final initialized = ref.watch(notificationInitializerProvider.future);

  final settingsAsync = ref.watch(settingsControllerProvider);
  final detailedSettings = ref.watch(detailedNotificationSettingsProvider);
  final repo = ref.watch(prayerRepositoryProvider);
  final dataSource = ref.watch(notificationDataSourceProvider);

  await initialized;
  if (settingsAsync.hasValue) {
    final settings = settingsAsync.value!;
    final now = DateTime.now();

    final previous = _schedulingQueue;
    final task = () async {
      await previous.catchError((Object _) {});
      await dataSource.cancelAll();
      {
        if (!settings.notificationsEnabled || !detailedSettings.globalEnabled)
          return;

        int alarmIdCounter = 100;

        // Schedule for next 5 days (5 days * 9 = 45 alarms, safely within limits)
        for (int dayOffset = 0; dayOffset < 5; dayOffset++) {
          final targetDate = now.add(Duration(days: dayOffset));
          try {
            final calendar = await repo.getPrayerCalendar(targetDate,
                method: settings.calculationMethod);
            final day = calendar.firstWhere((day) =>
                day.date.year == targetDate.year &&
                day.date.month == targetDate.month &&
                day.date.day == targetDate.day);
            // Build date-adjusted prayer day for targetDate
            final adjustedDay =
                DateTime(targetDate.year, targetDate.month, targetDate.day);

            // 1. Main Prayers
            for (final prayer in day.prayers) {
              if (settings.mutedPrayers.contains(prayer.type)) continue;

              final configId = _getPrayerConfigId(prayer.type);
              final config = detailedSettings.mainPrayers.firstWhere(
                (c) => c.id == configId,
                orElse: () => PrayerNotificationConfig(
                    id: configId, name: prayer.type.label, enabled: true),
              );

              if (!config.enabled) continue;

              final baseTime = DateTime(
                adjustedDay.year,
                adjustedDay.month,
                adjustedDay.day,
                prayer.time.hour,
                prayer.time.minute,
                prayer.time.second,
              );

              final scheduledTime =
                  baseTime.add(Duration(seconds: config.offsetSeconds));

              if (scheduledTime.isBefore(now)) continue;

              final timeStr = DateFormat('HH:mm').format(baseTime);
              final titleText = config.formatTitle(prayer.type.label, timeStr);
              final bodyText = config.formatBody(prayer.type.label, timeStr);

              alarmIdCounter++;
              await dataSource.schedulePrayerNotification(
                id: alarmIdCounter,
                title: titleText,
                body: bodyText,
                scheduledTime: scheduledTime,
                soundType: config.sound,
                customAudioPath: config.customAudioName,
                targetRoute: config.targetRoute,
                payload: '{"prayerId":"$configId","type":"main_prayer"}',
              );
            }

            // 2. Nafl Prayers
            final sunrise = day.byType(PrayerType.sunrise);
            final fajr = day.byType(PrayerType.fajr);
            final isha = day.byType(PrayerType.isha);

            // Ishroq
            final ishraqConfig = detailedSettings.naflPrayers.firstWhere(
              (p) => p.id == 'ishraq',
              orElse: () => const PrayerNotificationConfig(
                  id: 'ishraq', name: 'Ishroq', enabled: true),
            );
            if (ishraqConfig.enabled && sunrise != null) {
              final baseTime = DateTime(
                adjustedDay.year,
                adjustedDay.month,
                adjustedDay.day,
                sunrise.time.hour,
                sunrise.time.minute,
                sunrise.time.second,
              ).add(const Duration(minutes: 15));

              final ishraqTime =
                  baseTime.add(Duration(seconds: ishraqConfig.offsetSeconds));
              if (!ishraqTime.isBefore(now)) {
                final timeStr = DateFormat('HH:mm').format(baseTime);
                alarmIdCounter++;
                await dataSource.schedulePrayerNotification(
                  id: alarmIdCounter,
                  title: ishraqConfig.formatTitle('Ishroq', timeStr),
                  body: ishraqConfig.formatBody('Ishroq', timeStr),
                  scheduledTime: ishraqTime,
                  soundType: ishraqConfig.sound,
                  customAudioPath: ishraqConfig.customAudioName,
                  targetRoute: ishraqConfig.targetRoute,
                  payload: '{"prayerId":"ishraq","type":"nafl_prayer"}',
                );
              }
            }

            // Zuho
            final duhaConfig = detailedSettings.naflPrayers.firstWhere(
              (p) => p.id == 'duha',
              orElse: () => const PrayerNotificationConfig(
                  id: 'duha', name: 'Zuho', enabled: true),
            );
            if (duhaConfig.enabled && sunrise != null) {
              final baseTime = DateTime(
                adjustedDay.year,
                adjustedDay.month,
                adjustedDay.day,
                sunrise.time.hour,
                sunrise.time.minute,
                sunrise.time.second,
              ).add(const Duration(minutes: 30));

              final duhaTime =
                  baseTime.add(Duration(seconds: duhaConfig.offsetSeconds));
              if (!duhaTime.isBefore(now)) {
                final timeStr = DateFormat('HH:mm').format(baseTime);
                alarmIdCounter++;
                await dataSource.schedulePrayerNotification(
                  id: alarmIdCounter,
                  title: duhaConfig.formatTitle('Zuho', timeStr),
                  body: duhaConfig.formatBody('Zuho', timeStr),
                  scheduledTime: duhaTime,
                  soundType: duhaConfig.sound,
                  customAudioPath: duhaConfig.customAudioName,
                  targetRoute: duhaConfig.targetRoute,
                  payload: '{"prayerId":"duha","type":"nafl_prayer"}',
                );
              }
            }

            // Tahajjud
            final tahajjudConfig = detailedSettings.naflPrayers.firstWhere(
              (p) => p.id == 'tahajjud',
              orElse: () => const PrayerNotificationConfig(
                  id: 'tahajjud', name: 'Tahajjud', enabled: true),
            );
            if (tahajjudConfig.enabled && isha != null && fajr != null) {
              final ishaTime = DateTime(
                adjustedDay.year,
                adjustedDay.month,
                adjustedDay.day,
                isha.time.hour,
                isha.time.minute,
              );
              final tomorrowFajr = DateTime(
                adjustedDay.year,
                adjustedDay.month,
                adjustedDay.day + 1,
                fajr.time.hour,
                fajr.time.minute,
              );
              final nightSecs = tomorrowFajr.difference(ishaTime).inSeconds;
              final baseTime =
                  ishaTime.add(Duration(seconds: (nightSecs * 2 / 3).round()));
              final tahajjudTime =
                  baseTime.add(Duration(seconds: tahajjudConfig.offsetSeconds));

              if (!tahajjudTime.isBefore(now)) {
                final timeStr = DateFormat('HH:mm').format(baseTime);
                alarmIdCounter++;
                await dataSource.schedulePrayerNotification(
                  id: alarmIdCounter,
                  title: tahajjudConfig.formatTitle('Tahajjud', timeStr),
                  body: tahajjudConfig.formatBody('Tahajjud', timeStr),
                  scheduledTime: tahajjudTime,
                  soundType: tahajjudConfig.sound,
                  customAudioPath: tahajjudConfig.customAudioName,
                  targetRoute: tahajjudConfig.targetRoute,
                  payload: '{"prayerId":"tahajjud","type":"nafl_prayer"}',
                );
              }
            }
          } catch (error, stack) {
            debugPrint("Reminder scheduling failed: $error\n$stack");
            rethrow;
          }
        }
      }
    }();
    _schedulingQueue = task;
    await task;
  }
});

/// Reschedules all reminders on demand.
Future<void> rescheduleAllReminders(WidgetRef ref) async {
  ref.invalidate(notificationSchedulerProvider);
  await ref.read(notificationSchedulerProvider.future);
}

/// In-app live ticker for exact minute notifications when app is active in foreground.
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
    {
      final day = prayerDayAsync.value!;
      final settings = settingsAsync.value!;

      for (final prayer in day.prayers) {
        if (settings.mutedPrayers.contains(prayer.type)) continue;

        final configId = _getPrayerConfigId(prayer.type);
        final config = detailedSettings.mainPrayers.firstWhere(
          (c) => c.id == configId,
          orElse: () => PrayerNotificationConfig(
              id: configId, name: prayer.type.label, enabled: true),
        );

        if (!config.enabled) continue;

        final targetTime =
            prayer.time.add(Duration(seconds: config.offsetSeconds));

        if (isReminderDue(now, targetTime)) {
          final key =
              '${configId}_${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}';

          if (!_triggeredInAppKeys.contains(key)) {
            _triggeredInAppKeys.add(key);

            final timeStr = DateFormat('HH:mm').format(prayer.time);
            final titleText = config.formatTitle(prayer.type.label, timeStr);
            final bodyText = config.formatBody(prayer.type.label, timeStr);

            dataSource.showImmediateTestNotification(
              title: titleText,
              body: bodyText,
              soundType: config.sound,
              customAudioPath: config.customAudioName,
              targetRoute: config.targetRoute,
              payload: '{"prayerId":"$configId","type":"in_app_ticker"}',
            ).catchError((Object error, StackTrace stack) {
              debugPrint('Foreground reminder failed: $error\n$stack');
            });
          }
        }
      }
    }
  }
});
