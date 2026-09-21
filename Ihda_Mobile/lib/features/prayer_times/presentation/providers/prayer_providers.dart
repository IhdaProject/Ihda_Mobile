import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/network/api_client.dart';
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
/// derived from today's data + the live clock.
class PrayerCountdown {
  final Prayer? current;
  final Prayer? next;
  final Duration? remaining;
  const PrayerCountdown({this.current, this.next, this.remaining});
}

final prayerCountdownProvider = Provider.autoDispose<AsyncValue<PrayerCountdown>>((ref) {
  final dayAsync = ref.watch(todayPrayerDayProvider);
  final nowAsync = ref.watch(clockTickProvider);

  return dayAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
    data: (day) {
      final now = nowAsync.valueOrNull ?? DateTime.now();
      final next = day.nextPrayer(now);
      return AsyncData(
        PrayerCountdown(
          current: day.currentPrayer(now),
          next: next,
          remaining: next != null ? next.time.difference(now) : null,
        ),
      );
    },
  );
});
