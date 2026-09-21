import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_day.dart';

abstract class PrayerDataSource {
  Future<PrayerDay> getTodayPrayerTimes({CalculationMethod? method});
  Future<List<PrayerDay>> getPrayerCalendar(DateTime month, {CalculationMethod? method});
}
