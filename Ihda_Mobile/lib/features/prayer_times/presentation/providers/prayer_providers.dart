import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/network/api_client.dart';
import '../../../notifications/domain/entities/notification_settings.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
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
final todayPrayerDayProvider = FutureProvider.autoDispose<PrayerDay>((ref) async {
  final settings = await ref.watch(settingsControllerProvider.future);
  return ref.watch(prayerRepositoryProvider).getTodayPrayerTimes(
        method: settings.calculationMethod,
      );
});

/// A whole month for the calendar screen. Parameterized by the first-of-month date.
final prayerCalendarProvider =
    FutureProvider.autoDispose.family<List<PrayerDay>, DateTime>((ref, month) async {
  final settings = await ref.watch(settingsControllerProvider.future);
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
  final String? customLabel;
  final String? timeBadge;
  final bool hideHourglass;
  final bool isIshraqActive;
  final bool isTahajjudActive;

  const PrayerCountdown({
    this.current,
    this.next,
    this.remaining,
    this.isTomorrowFajr = false,
    this.customLabel,
    this.timeBadge,
    this.hideHourglass = false,
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

      // Check Nafl enabled settings
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
      final ishaToday = day.byType(PrayerType.isha);

      Prayer? next = day.nextPrayer(now);
      Prayer? current = day.currentPrayer(now);

      bool isTomorrowFajr = false;
      String? customLabel;
      String? timeBadge;
      bool hideHourglass = false;
      bool isIshraqActive = false;
      bool isTahajjudActive = false;
      Duration? remainingOverride;

      // 1. Calculate Tahajjud time (after 2/3 of night between Xufton and Tomorrow's Bomdod)
      DateTime? tahajjudStartTime;
      if (ishaToday != null && fajrToday != null) {
        final tomorrowFajrTime = fajrToday.time.add(const Duration(days: 1));
        final nightDurationSecs = tomorrowFajrTime.difference(ishaToday.time).inSeconds;
        tahajjudStartTime = ishaToday.time.add(Duration(seconds: (nightDurationSecs * 2 / 3).round()));
      }

      // 2. Check Tahajjud Window (Between 2/3 night and Fajr)
      if (tahajjudStartTime != null && !now.isBefore(tahajjudStartTime)) {
        final tomorrowFajrTime = fajrToday!.time.add(const Duration(days: 1));
        if (now.isBefore(tomorrowFajrTime)) {
          isTahajjudActive = true;
          next = Prayer(type: PrayerType.fajr, time: tomorrowFajrTime);
          isTomorrowFajr = true;
          if (tahajjudConfig.enabled) {
            customLabel = 'Tahajjud vaqti';
          } else {
            customLabel = 'Bomdod kirishi (Ertangi)';
          }
        }
      }

      // 3. Handle late night before Tahajjud (Between Xufton and Tahajjud start)
      if (next == null && !isTahajjudActive) {
        if (fajrToday != null) {
          final tomorrowFajrTime = fajrToday.time.add(const Duration(days: 1));
          next = Prayer(type: PrayerType.fajr, time: tomorrowFajrTime);
          isTomorrowFajr = true;
          if (tahajjudStartTime != null && tahajjudConfig.enabled && now.isBefore(tahajjudStartTime)) {
            next = Prayer(type: PrayerType.fajr, time: tahajjudStartTime);
            customLabel = 'Tahajjud kirishi';
            isTomorrowFajr = false;
          } else {
            customLabel = 'Bomdod kirishi (Ertangi)';
          }
        }
      }

      // 4. Handle Kirish / Chiqish & Nafl prayers between Sunrise and Dhuhr
      if (next != null && next.type == PrayerType.dhuhr && sunrise != null && dhuhr != null) {
        final ishraqStart = sunrise.time.add(const Duration(minutes: 15));
        final ishraqEnd = sunrise.time.add(const Duration(minutes: 30));
        final duhaStart = ishraqEnd;
        final duhaEnd = dhuhr.time.subtract(const Duration(minutes: 40));

        // A. Sunrise -> Ishroq Start (0 - 15 mins after Sunrise: Bomdod chiqishi / Quyosh)
        if (now.isAfter(sunrise.time) && now.isBefore(ishraqStart)) {
          if (ishraqConfig.enabled) {
            next = Prayer(type: PrayerType.sunrise, time: ishraqStart);
            customLabel = 'Ishroq kirishi';
            hideHourglass = true;
          } else {
            customLabel = 'Ishroq chiqishi';
            hideHourglass = true;
          }
        }
        // B. Ishroq Window (15 - 30 mins after Sunrise)
        else if (!now.isBefore(ishraqStart) && now.isBefore(ishraqEnd)) {
          if (ishraqConfig.enabled) {
            next = Prayer(type: PrayerType.sunrise, time: ishraqEnd);
            customLabel = 'Ishroq kirishi';
            isIshraqActive = true;
            remainingOverride = ishraqEnd.difference(now);
          } else {
            customLabel = 'Ishroq chiqishi';
          }
        }
        // C. Zuho Window (30 mins after Sunrise -> 40 mins before Dhuhr)
        else if (!now.isBefore(duhaStart) && now.isBefore(duhaEnd)) {
          if (duhaConfig.enabled) {
            next = Prayer(type: PrayerType.dhuhr, time: duhaEnd);
            customLabel = 'Zuho kirishi';
            remainingOverride = duhaEnd.difference(now);
          }
        }
        // D. Zaval / Makruh gap before Dhuhr (last 40 mins before Dhuhr)
        else if (!now.isBefore(duhaEnd) && now.isBefore(dhuhr.time)) {
          customLabel = 'Peshshin kirishi';
          hideHourglass = true;
        }
      }

      // Standard main prayer kirish labels
      if (customLabel == null && next != null) {
        switch (next.type) {
          case PrayerType.fajr:
            customLabel = isTomorrowFajr ? 'Bomdod kirishi (Ertangi)' : 'Bomdod kirishi';
            break;
          case PrayerType.dhuhr:
            customLabel = 'Peshshin kirishi';
            break;
          case PrayerType.asr:
            customLabel = 'Asr kirishi';
            break;
          case PrayerType.maghrib:
            customLabel = 'Shom kirishi';
            break;
          case PrayerType.isha:
            customLabel = 'Xufton kirishi';
            break;
          case PrayerType.sunrise:
            customLabel = 'Quyosh chiqishi';
            break;
        }
      }

      final remaining = remainingOverride ?? (next != null ? next.time.difference(now) : null);

      return AsyncData(
        PrayerCountdown(
          current: current,
          next: next,
          remaining: remaining,
          isTomorrowFajr: isTomorrowFajr,
          customLabel: customLabel,
          timeBadge: timeBadge,
          hideHourglass: hideHourglass,
          isIshraqActive: isIshraqActive,
          isTahajjudActive: isTahajjudActive,
        ),
      );
    },
  );
});
