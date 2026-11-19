class PrayerScheduleRow {
  final String label; // Bomdod, Peshin, Asr, Shom, Xufton
  final String azon;
  final String iqama;

  const PrayerScheduleRow({required this.label, required this.azon, required this.iqama});
}

class Mosque {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String distanceLabel;
  final double latitude;
  final double longitude;
  final bool isFavorite;
  final bool isVisited;
  final List<DateTime> visitDates;
  final List<PrayerScheduleRow> schedule;

  const Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.distanceLabel,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    this.isVisited = false,
    this.visitDates = const [],
    this.schedule = const [],
  });

  int get visitCount => visitDates.isNotEmpty ? visitDates.length : (isVisited ? 1 : 0);

  DateTime? get lastVisitedAt => visitDates.isNotEmpty ? visitDates.last : null;

  Mosque copyWith({
    bool? isFavorite,
    bool? isVisited,
    List<DateTime>? visitDates,
  }) =>
      Mosque(
        id: id,
        name: name,
        address: address,
        phone: phone,
        distanceLabel: distanceLabel,
        latitude: latitude,
        longitude: longitude,
        isFavorite: isFavorite ?? this.isFavorite,
        isVisited: isVisited ?? this.isVisited,
        visitDates: visitDates ?? this.visitDates,
        schedule: schedule,
      );
}
