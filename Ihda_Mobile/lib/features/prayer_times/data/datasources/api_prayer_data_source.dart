import '../../../../core/network/api_client.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_day.dart';
import '../models/prayer_day_model.dart';
import 'prayer_data_source.dart';

/// Real backend implementation. Not wired up until
/// AppEnvironment.dataSourceMode is switched to DataSourceMode.api -
/// adjust the endpoint paths/params below to match your actual API.
class ApiPrayerDataSource implements PrayerDataSource {
  final ApiClient _client;

  ApiPrayerDataSource(this._client);

  @override
  Future<PrayerDay> getTodayPrayerTimes({CalculationMethod? method}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/prayer-times/today',
      query: {if (method != null) 'method': method.name},
    );
    return PrayerDayModel.fromJson(response.data!).toEntity();
  }

  @override
  Future<List<PrayerDay>> getPrayerCalendar(DateTime month, {CalculationMethod? method}) async {
    final response = await _client.get<List<dynamic>>(
      '/prayer-times/calendar',
      query: {
        'year': month.year,
        'month': month.month,
        if (method != null) 'method': method.name,
      },
    );
    return (response.data ?? [])
        .map((e) => PrayerDayModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }
}
