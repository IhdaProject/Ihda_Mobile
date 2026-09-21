import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_day.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_data_source.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerDataSource _dataSource;

  PrayerRepositoryImpl(this._dataSource);

  @override
  Future<PrayerDay> getTodayPrayerTimes({CalculationMethod? method}) =>
      _dataSource.getTodayPrayerTimes(method: method);

  @override
  Future<List<PrayerDay>> getPrayerCalendar(DateTime month, {CalculationMethod? method}) =>
      _dataSource.getPrayerCalendar(month, method: method);
}
