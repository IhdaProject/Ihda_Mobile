import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/network/api_client.dart';
import '../../../notifications/domain/entities/notification_settings.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/datasources/api_prayer_data_source.dart';
import '../../data/datasources/mock_prayer_data_source.dart';
import '../../data/datasources/prayer_data_source.dart';
import '../../data/repositories/prayer_repository_impl.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_day.dart';
import '../../domain/repositories/prayer_repository.dart';

/// The ONLY place that picks mock vs. API. Everything downstream
/// (repository, controllers, UI) is unaware of the choice.
final prayerDataSourceProvider = Provider<PrayerDataSource>((ref) {
  switch (AppEnvironment.dataSourceMode) {
    case DataSourceMode.mock:
      return MockPrayerDataSource();
    case DataSourceMode.api:
      return ApiPrayerDataSource(ApiClient());
  }
});

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepositoryImpl(ref.watch(prayerDataSourceProvider));
});

/// Today's prayer times, re-fetched whenever the calculation method changes.
final todayPrayerDayProvider = FutureProvider.autoDispose<PrayerDay>((ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull ?? const AppSettings();
  return ref.watch(prayerRepositoryProvider).getTodayPrayerTimes(
        method: settings.calculationMethod,
      );
});

/// A whole month for the calendar screen. Parameterized by the first-of-month date.
final prayerCalendarProvider =
    FutureProvider.autoDispose.family<List<PrayerDay>, DateTime>((ref, month) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull ?? const AppSettings();
  return ref.watch(prayerRepositoryProvider).getPrayerCalendar(
        month,
        method: settings.calculationMethod,
      );
});

/// Ticks once a second so the home screen's countdown stays live.
final clockTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now())
      .startsWith(DateTime.now());
});

extension on Stream<DateTime> {
  Stream<DateTime> startsWith(DateTime initial) async* {
    yield initial;
    yield* this;
  }
}

/// Convenience: (current prayer, next prayer, time remaining) bundle
/// derived from today's data + Nafl & Tahajjud settings + live clock.
class PrayerCountdown {
  final Prayer? current;
  final Prayer? next;
  final Duration? remaining;
  final bool isTomorrowFajr;
  final String displayTitle;
  final String countdownSubtitle;
  final bool hideHourglass;
  final int yellowWarningMinutes;
  final int redWarningMinutes;
  final bool isIshraqActive;
  final bool isTahajjudActive;

  const PrayerCountdown({
    this.current,
    this.next,
    this.remaining,
    this.isTomorrowFajr = false,
    required this.displayTitle,
    required this.countdownSubtitle,
    this.hideHourglass = false,
    this.yellowWarningMinutes = 30,
    this.redWarningMinutes = 15,
    this.isIshraqActive = false,
    this.isTahajjudActive = false,
  });
}

final prayerCountdownProvider = Provider.autoDispose<AsyncValue<PrayerCountdown>>((ref) {
  final dayAsync = ref.watch(todayPrayerDayProvider);
  final nowAsync = ref.watch(clockTickProvider);
  final detailedSettings = ref.watch(detailedNotificationSettingsProvider);

  return dayAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
    data: (day) {
      final now = nowAsync.valueOrNull ?? DateTime.now();

      final ishraqConfig = detailedSettings.naflPrayers.firstWhere(
        (p) => p.id == 'ishraq',
        orElse: () => const PrayerNotificationConfig(id: 'ishraq', name: 'Ishroq', enabled: true),
      );
      final duhaConfig = detailedSettings.naflPrayers.firstWhere(
        (p) => p.id == 'duha',
        orElse: () => const PrayerNotificationConfig(id: 'duha', name: 'Zuho', enabled: true),
      );
      final tahajjudConfig = detailedSettings.naflPrayers.firstWhere(
        (p) => p.id == 'tahajjud',
        orElse: () => const PrayerNotificationConfig(id: 'tahajjud', name: 'Tahajjud', enabled: true),
      );

      final fajrToday = day.byType(PrayerType.fajr);
      final sunrise = day.byType(PrayerType.sunrise);
      final dhuhr = day.byType(PrayerType.dhuhr);
      final asr = day.byType(PrayerType.asr);
      final maghrib = day.byType(PrayerType.maghrib);
      final ishaToday = day.byType(PrayerType.isha);

      Prayer? current = day.currentPrayer(now);

      String displayTitle = 'Kutish...';
      String countdownSubtitle = 'Qolgan vaqt:';
      bool hideHourglass = false;
      int yellowWarningMinutes = 30;
      int redWarningMinutes = 15;
      bool isTomorrowFajr = false;
      bool isIshraqActive = false;
      bool isTahajjudActive = false;
      Prayer? nextTarget;
      DateTime? targetTime;

      // -------------------------------------------------------------
      // TIMELINE COMPUTATION (RULES 1 TO 13)
      // -------------------------------------------------------------

      if (fajrToday != null && sunrise != null && dhuhr != null && asr != null && maghrib != null && ishaToday != null) {
        final tomorrowFajrTime = fajrToday.time.add(const Duration(days: 1));

        // 1. Bomdod active (Fajr -> Sunrise) => RULE 6
        if (!now.isBefore(fajrToday.time) && now.isBefore(sunrise.time)) {
          nextTarget = sunrise;
          targetTime = sunrise.time;
          displayTitle = 'Quyosh chiqishi';
          countdownSubtitle = 'Quyosh chiqishiga qolgan vaqt';
          hideHourglass = false;
          yellowWarningMinutes = 30;
          redWarningMinutes = 15;
        }
        // 2. Sunrise -> Dhuhr gap => RULES 7, 8, 9, 10, 11, 12, 13
        else if (!now.isBefore(sunrise.time) && now.isBefore(dhuhr.time)) {
          final ishraqStart = sunrise.time.add(const Duration(minutes: 15));
          final ishraqEnd = sunrise.time.add(const Duration(minutes: 30));
          final zuhoStart = ishraqEnd;
          final zuhoEnd = dhuhr.time.subtract(const Duration(minutes: 40));

          // 2A. Sunrise -> Ishroq Start (0-15 mins after Sunrise)
          if (now.isBefore(ishraqStart)) {
            if (ishraqConfig.enabled) {
              // RULE 9: Ishroq yoniq
              nextTarget = Prayer(type: PrayerType.sunrise, time: ishraqStart);
              targetTime = ishraqStart;
              displayTitle = 'Ishroq kirishi';
              countdownSubtitle = 'Ishroqqacha qolgan vaqt';
              hideHourglass = true;
            } else if (duhaConfig.enabled) {
              // RULE 8: Zuho yongan, Ishroq o'chiq
              nextTarget = Prayer(type: PrayerType.dhuhr, time: zuhoStart);
              targetTime = zuhoStart;
              displayTitle = 'Zuho kirishi';
              countdownSubtitle = 'Zuhogacha qolgan vaqt';
              hideHourglass = true;
            } else {
              // RULE 7: Ishroq ham, Zuho ham o'chiq
              nextTarget = dhuhr;
              targetTime = dhuhr.time;
              displayTitle = 'Peshin kirishi';
              countdownSubtitle = 'Peshingacha qolgan vaqt';
              hideHourglass = true;
            }
          }
          // 2B. Ishroq Window (15-30 mins after Sunrise)
          else if (!now.isBefore(ishraqStart) && now.isBefore(ishraqEnd)) {
            if (ishraqConfig.enabled) {
              isIshraqActive = true;
              if (duhaConfig.enabled) {
                // RULE 11: Ishroq kirdi, Zuho yoniq
                nextTarget = Prayer(type: PrayerType.dhuhr, time: zuhoStart);
                targetTime = zuhoStart;
                displayTitle = 'Zuho kirishi';
                countdownSubtitle = 'Zuhogacha qolgan vaqt';
                hideHourglass = false;
                yellowWarningMinutes = 10;
                redWarningMinutes = 5;
              } else {
                // RULE 10: Ishroq kirdi, Zuho o'chiq
                nextTarget = Prayer(type: PrayerType.sunrise, time: ishraqEnd);
                targetTime = ishraqEnd;
                displayTitle = 'Ishroq chiqishi';
                countdownSubtitle = 'Ishroq chiqishiga qolgan vaqt';
                hideHourglass = false;
                yellowWarningMinutes = 10;
                redWarningMinutes = 5;
              }
            } else if (duhaConfig.enabled) {
              // RULE 8
              nextTarget = Prayer(type: PrayerType.dhuhr, time: zuhoStart);
              targetTime = zuhoStart;
              displayTitle = 'Zuho kirishi';
              countdownSubtitle = 'Zuhogacha qolgan vaqt';
              hideHourglass = true;
            } else {
              // RULE 7
              nextTarget = dhuhr;
              targetTime = dhuhr.time;
              displayTitle = 'Peshin kirishi';
              countdownSubtitle = 'Peshingacha qolgan vaqt';
              hideHourglass = true;
            }
          }
          // 2C. Zuho Window (30 mins after Sunrise -> Dhuhr - 40 mins)
          else if (!now.isBefore(zuhoStart) && now.isBefore(zuhoEnd)) {
            if (duhaConfig.enabled) {
              // RULE 12: Zuho kirdi
              nextTarget = Prayer(type: PrayerType.dhuhr, time: zuhoEnd);
              targetTime = zuhoEnd;
              displayTitle = 'Zuho chiqishi';
              countdownSubtitle = 'Zuho chiqishiga qolgan vaqt';
              hideHourglass = false;
              yellowWarningMinutes = 30;
              redWarningMinutes = 15;
            } else {
              // RULE 7: Zuho o'chiq
              nextTarget = dhuhr;
              targetTime = dhuhr.time;
              displayTitle = 'Peshin kirishi';
              countdownSubtitle = 'Peshingacha qolgan vaqt';
              hideHourglass = true;
            }
          }
          // 2D. Zaval Gap (last 40 mins before Dhuhr)
          else {
            // RULE 13: Zuho chiqdi
            nextTarget = dhuhr;
            targetTime = dhuhr.time;
            displayTitle = 'Peshin kirishi';
            countdownSubtitle = 'Peshingacha qolgan vaqt';
            hideHourglass = true;
          }
        }
        // 3. Peshin active (Dhuhr -> Asr) => RULE 1
        else if (!now.isBefore(dhuhr.time) && now.isBefore(asr.time)) {
          nextTarget = asr;
          targetTime = asr.time;
          displayTitle = 'Asr kirishi';
          countdownSubtitle = 'Asrga qolgan vaqt';
          hideHourglass = false;
          yellowWarningMinutes = 30;
          redWarningMinutes = 15;
        }
        // 4. Asr active (Asr -> Maghrib) => RULE 2
        else if (!now.isBefore(asr.time) && now.isBefore(maghrib.time)) {
          nextTarget = maghrib;
          targetTime = maghrib.time;
          displayTitle = 'Shom kirishi';
          countdownSubtitle = 'Shomga qolgan vaqt';
          hideHourglass = false;
          yellowWarningMinutes = 30;
          redWarningMinutes = 15;
        }
        // 5. Shom active (Maghrib -> Isha) => RULE 3
        else if (!now.isBefore(maghrib.time) && now.isBefore(ishaToday.time)) {
          nextTarget = ishaToday;
          targetTime = ishaToday.time;
          displayTitle = 'Xufton kirishi';
          countdownSubtitle = 'Xuftonga qolgan vaqt';
          hideHourglass = false;
          yellowWarningMinutes = 40;
          redWarningMinutes = 25;
        }
        // 6. Xufton active / Night => RULES 4 & 5
        else {
          final nightSecs = tomorrowFajrTime.difference(ishaToday.time).inSeconds;
          final tahajjudStart = ishaToday.time.add(Duration(seconds: (nightSecs * 2 / 3).round()));

          if (tahajjudConfig.enabled) {
            // RULE 5: Tahajjud yoqilgan
            if (now.isBefore(tahajjudStart)) {
              // Rule 5 Phase A: Before Tahajjud Start
              nextTarget = Prayer(type: PrayerType.fajr, time: tahajjudStart);
              targetTime = tahajjudStart;
              displayTitle = 'Tahajjud qiyom vaqti';
              countdownSubtitle = 'Tahajjudgacha qolgan vaqt';
              hideHourglass = true;
            } else {
              // Rule 5 Phase B: After Tahajjud Start (Qiyom vaqti kirdi)
              isTahajjudActive = true;
              isTomorrowFajr = true;
              nextTarget = Prayer(type: PrayerType.fajr, time: tomorrowFajrTime);
              targetTime = tomorrowFajrTime;
              displayTitle = 'Bomdod kirishi';
              countdownSubtitle = 'Bomdodga qolgan vaqt';
              hideHourglass = false;
              yellowWarningMinutes = 30;
              redWarningMinutes = 15;
            }
          } else {
            // RULE 4: Tahajjud o'chiq
            isTomorrowFajr = true;
            nextTarget = Prayer(type: PrayerType.fajr, time: tomorrowFajrTime);
            targetTime = tomorrowFajrTime;
            displayTitle = 'Bomdod kirishi';
            countdownSubtitle = 'Bomdodga qolgan vaqt';
            hideHourglass = false;
            yellowWarningMinutes = 30;
            redWarningMinutes = 15;
          }
        }
      }

      final Duration? remaining = targetTime != null ? targetTime.difference(now) : null;

      return AsyncData(
        PrayerCountdown(
          current: current,
          next: nextTarget,
          remaining: remaining,
          isTomorrowFajr: isTomorrowFajr,
          displayTitle: displayTitle,
          countdownSubtitle: countdownSubtitle,
          hideHourglass: hideHourglass,
          yellowWarningMinutes: yellowWarningMinutes,
          redWarningMinutes: redWarningMinutes,
          isIshraqActive: isIshraqActive,
          isTahajjudActive: isTahajjudActive,
        ),
      );
    },
  );
});
