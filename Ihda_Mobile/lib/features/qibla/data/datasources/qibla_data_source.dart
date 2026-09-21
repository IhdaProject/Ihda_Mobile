import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/qibla_data.dart';

abstract class QiblaDataSource {
  /// Bearing from a given location to the Kaaba, in degrees from true north.
  double calculateQiblaBearing(double latitude, double longitude);

  /// Stream of device compass headings.
  Stream<CompassEvent> compassStream();
}

class RealQiblaDataSource implements QiblaDataSource {
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  @override
  double calculateQiblaBearing(double latitude, double longitude) {
    final lat1 = _toRad(latitude);
    final lat2 = _toRad(_kaabaLat);
    final dLng = _toRad(_kaabaLng - longitude);

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  @override
  Stream<CompassEvent> compassStream() {
    return FlutterCompass.events ?? const Stream.empty();
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
