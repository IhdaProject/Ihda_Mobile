import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../location/presentation/providers/location_providers.dart';
import '../../data/datasources/qibla_data_source.dart';
import '../../domain/entities/qibla_data.dart';

final qiblaDataSourceProvider = Provider<QiblaDataSource>((ref) {
  return RealQiblaDataSource();
});

final compassStreamProvider = StreamProvider.autoDispose<CompassEvent>((ref) {
  return ref.watch(qiblaDataSourceProvider).compassStream();
});

final qiblaDataProvider = Provider.autoDispose<AsyncValue<QiblaData>>((ref) {
  final locationAsync = ref.watch(currentLocationProvider);
  final compassAsync = ref.watch(compassStreamProvider);

  if (locationAsync.isLoading || compassAsync.isLoading) return const AsyncLoading();
  if (locationAsync.hasError) return AsyncError(locationAsync.error!, locationAsync.stackTrace!);
  if (compassAsync.hasError) return AsyncError(compassAsync.error!, compassAsync.stackTrace!);

  final location = locationAsync.value!;
  final heading = compassAsync.value?.heading ?? 0;
  final bearing = ref.read(qiblaDataSourceProvider).calculateQiblaBearing(location.latitude, location.longitude);

  return AsyncData(QiblaData(
    qiblaBearing: bearing,
    deviceHeading: heading,
  ));
});
