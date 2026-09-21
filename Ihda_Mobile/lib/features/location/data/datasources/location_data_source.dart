import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/app_location.dart';

abstract class LocationDataSource {
  Future<AppLocation> getCurrentLocation();
}

/// Returns a fixed mock location. No permission prompts, so the app never
/// depends on device location capability to run.
///
/// Swap this for a real `geolocator`-backed implementation later - the
/// interface above is all the rest of the app knows about.
class MockLocationDataSource implements LocationDataSource {
  @override
  Future<AppLocation> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const AppLocation(
      city: AppConstants.defaultCityName,
      country: AppConstants.defaultCountryName,
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
    );
  }
}
