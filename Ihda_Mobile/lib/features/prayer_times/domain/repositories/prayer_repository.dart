import '../entities/prayer.dart';
import '../entities/prayer_day.dart';

/// The UI and providers only ever depend on this interface - never on a
/// concrete mock/API data source. That's what makes switching
/// AppEnvironment.dataSourceMode a one-line change.
abstract class PrayerRepository {
  Future<PrayerDay> getTodayPrayerTimes({CalculationMethod? method});

  Future<List<PrayerDay>> getPrayerCalendar(DateTime month, {CalculationMethod? method});
}
