import '../../domain/entities/mosque.dart';
import 'mosque_data_source.dart';

/// Fictional/placeholder mosque list for the mock-data preview. Some names
/// reference well-known Tashkent landmarks purely as recognizable flavor
/// text; distances and schedules are made up.
class MockMosqueDataSource implements MosqueDataSource {
  static final List<Mosque> _mosques = [
    Mosque(
      id: 'm1',
      name: 'Minor Mosque',
      address: 'Amir Temur ko\'chasi, Tashkent',
      phone: '+998 71 234 56 78',
      distanceLabel: '350 m',
      latitude: 41.3208,
      longitude: 69.2652,
      isFavorite: true,
      schedule: const [
        PrayerScheduleRow(label: 'Bomdod', azon: '06:14', iqama: '06:40'),
        PrayerScheduleRow(label: 'Peshin', azon: '12:50', iqama: '13:05'),
        PrayerScheduleRow(label: 'Asr', azon: '16:00', iqama: '16:10'),
        PrayerScheduleRow(label: 'Shom', azon: '17:40', iqama: '17:40'),
        PrayerScheduleRow(label: 'Xufton', azon: '18:55', iqama: '19:10'),
      ],
    ),
    Mosque(
      id: 'm2',
      name: 'Hazrati Imam Mosque',
      address: 'Hazrati Imom majmuasi, Tashkent',
      phone: '+998 71 234 11 22',
      distanceLabel: '1.2 km',
      latitude: 41.3325,
      longitude: 69.2384,
      isFavorite: true,
      schedule: const [
        PrayerScheduleRow(label: 'Bomdod', azon: '06:10', iqama: '06:35'),
        PrayerScheduleRow(label: 'Peshin', azon: '12:45', iqama: '13:00'),
        PrayerScheduleRow(label: 'Asr', azon: '15:55', iqama: '16:05'),
        PrayerScheduleRow(label: 'Shom', azon: '17:35', iqama: '17:35'),
        PrayerScheduleRow(label: 'Xufton', azon: '18:50', iqama: '19:05'),
      ],
    ),
    Mosque(
      id: 'm3',
      name: 'Chorsu Mosque',
      address: 'Chorsu bozori yonida, Tashkent',
      phone: '+998 71 233 44 55',
      distanceLabel: '2.4 km',
      latitude: 41.3264,
      longitude: 69.2350,
      schedule: const [
        PrayerScheduleRow(label: 'Bomdod', azon: '06:16', iqama: '06:42'),
        PrayerScheduleRow(label: 'Peshin', azon: '12:52', iqama: '13:07'),
        PrayerScheduleRow(label: 'Asr', azon: '16:02', iqama: '16:12'),
        PrayerScheduleRow(label: 'Shom', azon: '17:42', iqama: '17:42'),
        PrayerScheduleRow(label: 'Xufton', azon: '18:57', iqama: '19:12'),
      ],
    ),
    Mosque(
      id: 'm4',
      name: 'Kukeldash Madrasah Mosque',
      address: 'Eski shahar, Tashkent',
      phone: '+998 71 235 66 77',
      distanceLabel: '2.8 km',
      latitude: 41.3271,
      longitude: 69.2361,
      schedule: const [
        PrayerScheduleRow(label: 'Bomdod', azon: '06:13', iqama: '06:39'),
        PrayerScheduleRow(label: 'Peshin', azon: '12:48', iqama: '13:03'),
        PrayerScheduleRow(label: 'Asr', azon: '15:58', iqama: '16:08'),
        PrayerScheduleRow(label: 'Shom', azon: '17:38', iqama: '17:38'),
        PrayerScheduleRow(label: 'Xufton', azon: '18:53', iqama: '19:08'),
      ],
    ),
    Mosque(
      id: 'm5',
      name: 'Tinchlik Mosque',
      address: 'Tinchlik tumani, Tashkent',
      phone: '+998 71 236 88 99',
      distanceLabel: '4.1 km',
      latitude: 41.3020,
      longitude: 69.2890,
      schedule: const [
        PrayerScheduleRow(label: 'Bomdod', azon: '06:15', iqama: '06:41'),
        PrayerScheduleRow(label: 'Peshin', azon: '12:51', iqama: '13:06'),
        PrayerScheduleRow(label: 'Asr', azon: '16:01', iqama: '16:11'),
        PrayerScheduleRow(label: 'Shom', azon: '17:41', iqama: '17:41'),
        PrayerScheduleRow(label: 'Xufton', azon: '18:56', iqama: '19:11'),
      ],
    ),
    Mosque(
      id: 'm6',
      name: 'Jome Mosque Yunusobod',
      address: 'Yunusobod tumani, Tashkent',
      phone: '+998 71 237 12 34',
      distanceLabel: '5.6 km',
      latitude: 41.3670,
      longitude: 69.2880,
      schedule: const [
        PrayerScheduleRow(label: 'Bomdod', azon: '06:12', iqama: '06:38'),
        PrayerScheduleRow(label: 'Peshin', azon: '12:47', iqama: '13:02'),
        PrayerScheduleRow(label: 'Asr', azon: '15:57', iqama: '16:07'),
        PrayerScheduleRow(label: 'Shom', azon: '17:37', iqama: '17:37'),
        PrayerScheduleRow(label: 'Xufton', azon: '18:52', iqama: '19:07'),
      ],
    ),
  ];

  @override
  Future<List<Mosque>> getNearbyMosques() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_mosques);
  }

  @override
  Future<Mosque> getMosqueById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mosques.firstWhere((m) => m.id == id);
  }

  @override
  Future<void> setFavorite(String id, bool isFavorite) async {
    final index = _mosques.indexWhere((m) => m.id == id);
    if (index != -1) {
      _mosques[index] = _mosques[index].copyWith(isFavorite: isFavorite);
    }
  }
}
