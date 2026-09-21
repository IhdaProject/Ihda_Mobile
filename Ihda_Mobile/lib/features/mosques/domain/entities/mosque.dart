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
    this.schedule = const [],
  });

  Mosque copyWith({bool? isFavorite}) => Mosque(
        id: id,
        name: name,
        address: address,
        phone: phone,
        distanceLabel: distanceLabel,
        latitude: latitude,
        longitude: longitude,
        isFavorite: isFavorite ?? this.isFavorite,
        schedule: schedule,
      );
}
