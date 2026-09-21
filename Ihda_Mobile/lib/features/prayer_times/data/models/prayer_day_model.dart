import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_day.dart';

/// Wire-format DTO. Mock data sources build [PrayerDay] directly; API data
/// sources decode into this model first, then call [toEntity].
class PrayerDayModel {
  final DateTime date;
  final Map<String, String> times; // "fajr": "05:12", etc. (HH:mm, local)

  const PrayerDayModel({required this.date, required this.times});

  factory PrayerDayModel.fromJson(Map<String, dynamic> json) {
    return PrayerDayModel(
      date: DateTime.parse(json['date'] as String),
      times: Map<String, String>.from(json['times'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'times': times,
      };

  PrayerDay toEntity() {
    DateTime timeFor(String hhmm) {
      final parts = hhmm.split(':');
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    return PrayerDay(
      date: date,
      prayers: [
        Prayer(type: PrayerType.fajr, time: timeFor(times['fajr']!)),
        Prayer(type: PrayerType.sunrise, time: timeFor(times['sunrise']!)),
        Prayer(type: PrayerType.dhuhr, time: timeFor(times['dhuhr']!)),
        Prayer(type: PrayerType.asr, time: timeFor(times['asr']!)),
        Prayer(type: PrayerType.maghrib, time: timeFor(times['maghrib']!)),
        Prayer(type: PrayerType.isha, time: timeFor(times['isha']!)),
      ],
    );
  }
}
