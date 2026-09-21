class AppLocation {
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final bool isDeviceLocation;

  const AppLocation({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isDeviceLocation = false,
  });
}
