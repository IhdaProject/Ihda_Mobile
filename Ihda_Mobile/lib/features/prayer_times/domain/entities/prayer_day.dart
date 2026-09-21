import 'prayer.dart';

class PrayerDay {
  final DateTime date;
  final List<Prayer> prayers;

  const PrayerDay({required this.date, required this.prayers});

  Prayer? byType(PrayerType type) {
    for (final p in prayers) {
      if (p.type == type) return p;
    }
    return null;
  }

  /// The prayer currently in effect (last one whose time has passed today).
  Prayer? currentPrayer(DateTime now) {
    Prayer? current;
    for (final p in prayers) {
      if (!p.time.isAfter(now)) {
        current = p;
      }
    }
    return current;
  }

  /// The next upcoming prayer, or null if all of today's prayers have passed.
  Prayer? nextPrayer(DateTime now) {
    for (final p in prayers) {
      if (p.time.isAfter(now)) return p;
    }
    return null;
  }
}
