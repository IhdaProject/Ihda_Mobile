class QiblaData {
  /// Bearing to the Qibla from true north, in degrees (0-360).
  final double qiblaBearing;

  /// Current device heading from true north, in degrees (0-360).
  final double deviceHeading;

  const QiblaData({required this.qiblaBearing, required this.deviceHeading});

  /// Degrees to rotate the Qibla indicator relative to the device heading.
  double get relativeDirection => (qiblaBearing - deviceHeading + 360) % 360;
}
