import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/location_data_source.dart';
import '../../domain/entities/app_location.dart';

final locationDataSourceProvider = Provider<LocationDataSource>((ref) {
  // Only a mock implementation exists today; add ApiLocationDataSource /
  // a geolocator-backed one and switch it here when ready.
  return MockLocationDataSource();
});

final currentLocationProvider = FutureProvider.autoDispose<AppLocation>((ref) {
  return ref.watch(locationDataSourceProvider).getCurrentLocation();
});
