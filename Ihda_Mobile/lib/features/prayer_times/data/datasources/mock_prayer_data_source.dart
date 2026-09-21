import 'dart:math' as math;

import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_day.dart';
import 'prayer_data_source.dart';

/// Generates realistic-looking prayer times without any network call.
/// Base times are roughly Tashkent-appropriate; a small daily drift is
/// applied so a full month looks natural rather than identical every day.
class MockPrayerDataSource implements PrayerDataSource {
  static const _baseMinutes = {
    PrayerType.fajr: 5 * 60 + 10,
    PrayerType.sunrise: 6 * 60 + 35,
    PrayerType.dhuhr: 12 * 60 + 30,
    PrayerType.asr: 16 * 60 + 5,
    PrayerType.maghrib: 19 * 60 + 20,
    PrayerType.isha: 20 * 60 + 45,
  };

  @override
  Future<PrayerDay> getTodayPrayerTimes({CalculationMethod? method}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _buildDay(DateTime.now(), method: method);
  }

  @override
  Future<List<PrayerDay>> getPrayerCalendar(DateTime month, {CalculationMethod? method}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (i) => _buildDay(DateTime(month.year, month.month, i + 1), method: method),
    );
  }

  PrayerDay _buildDay(DateTime date, {CalculationMethod? method}) {
    // Small deterministic drift per day-of-year so times shift gradually,
    // like real seasonal variation, plus a tiny offset per method.
    final dayOfYear = DateTime(date.year, date.month, date.day)
        .difference(DateTime(date.year, 1, 1))
        .inDays;
    final seasonalDriftMinutes =
        (10 * math.sin(2 * math.pi * dayOfYear / 365)).round();
    final methodOffset = _methodOffsetMinutes(method);

    final prayers = _baseMinutes.entries.map((entry) {
      final adjust = entry.key == PrayerType.fajr || entry.key == PrayerType.isha
          ? -seasonalDriftMinutes
          : seasonalDriftMinutes;
      final totalMinutes = entry.value + adjust + methodOffset;
      final hour = (totalMinutes ~/ 60) % 24;
      final minute = totalMinutes % 60;
      return Prayer(
        type: entry.key,
        time: DateTime(date.year, date.month, date.day, hour, minute),
      );
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return PrayerDay(date: date, prayers: prayers);
  }

  int _methodOffsetMinutes(CalculationMethod? method) {
    switch (method) {
      case CalculationMethod.isna:
        return 2;
      case CalculationMethod.egypt:
        return -3;
      case CalculationMethod.makkah:
        return 4;
      case CalculationMethod.karachi:
        return -1;
      case CalculationMethod.diyanet:
        return 1;
      case CalculationMethod.mwl:
      case null:
        return 0;
    }
  }
}
