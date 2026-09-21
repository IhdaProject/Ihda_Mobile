import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../mosques/presentation/providers/mosque_providers.dart';
import '../../../mosques/presentation/screens/mosque_detail_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  final Point? targetPoint;
  final String? targetName;

  const MapScreen({
    super.key,
    this.targetPoint,
    this.targetName,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  YandexMapController? _mapController;
  final List<MapObject> _mapObjects = [];
  Point? _userLocation;
  bool _isRouteActive = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = Point(latitude: pos.latitude, longitude: pos.longitude);
      });
      
      if (widget.targetPoint != null) {
        _moveToPoint(widget.targetPoint!);
        _buildRoute(widget.targetPoint!);
      } else {
        _moveToUser();
      }
    }
  }

  void _moveToUser() {
    if (_userLocation != null) {
      _moveToPoint(_userLocation!);
    }
  }

  void _moveToPoint(Point point) {
    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 15),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
    );
  }

  void _onMapCreated(YandexMapController controller) {
    _mapController = controller;
    if (widget.targetPoint != null) {
      _moveToPoint(widget.targetPoint!);
      _buildRoute(widget.targetPoint!);
    } else {
      _moveToUser();
    }
    _updateMosqueMarkers();
  }

  void _updateMosqueMarkers() {
    final mosques = ref.read(mosqueControllerProvider).valueOrNull ?? [];
    setState(() {
      _mapObjects.removeWhere((obj) => obj.mapId.value.startsWith('mosque_') || obj.mapId.value == 'user_location');
      
      // User marker
      if (_userLocation != null) {
        _mapObjects.add(
          PlacemarkMapObject(
            mapId: const MapObjectId('user_location'),
            point: _userLocation!,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('assets/app_icon.png'),
                scale: 0.1,
              ),
            ),
          ),
        );
      }

      // Mosque markers
      for (final mosque in mosques) {
        _mapObjects.add(
          PlacemarkMapObject(
            mapId: MapObjectId('mosque_${mosque.id}'),
            point: Point(latitude: mosque.latitude, longitude: mosque.longitude),
            onTap: (object, point) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MosqueDetailScreen(mosqueId: mosque.id)),
              );
            },
          ),
        );
      }
    });
  }

  Future<void> _buildRoute(Point target) async {
    if (_userLocation == null) return;

    setState(() {
      _isRouteActive = true;
      _mapObjects.removeWhere((obj) => obj.mapId.value == 'route_polyline');
    });

  Future<void> _buildRoute(Point target) async {
    if (_userLocation == null) return;

    setState(() {
      _isRouteActive = true;
      _mapObjects.removeWhere((obj) => obj.mapId.value == 'route_polyline');
    });

    // Note: yandex_mapkit_lite does not support automatic route calculation (DrivingRouter).
    // We draw a straight line as a visual indicator within the app.
    // For real turn-by-turn navigation, the user can use the "Tashqi xarita" button.
    final routePolyline = PolylineMapObject(
      mapId: const MapObjectId('route_polyline'),
      polyline: Polyline(points: [_userLocation!, target]),
      strokeColor: AppColors.primary,
      strokeWidth: 4,
      dashLength: 10,
      gapLength: 5,
    );

    setState(() {
      _mapObjects.add(routePolyline);
    });
  }
  }

  void _showNavigationOptions(double lat, double lon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Navigatsiyani tanlang', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.navigation_rounded, color: AppColors.primary),
                title: const Text('Yandex Navigator'),
                subtitle: const Text('Tavsiya etiladi'),
                onTap: () {
                  Navigator.pop(context);
                  _launchExternalMap('yandexmaps://maps.yandex.ru/?rtext=$_userLocation?.latitude,$_userLocation?.longitude~$lat,$lon&rtt=auto');
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_rounded, color: Colors.blue),
                title: const Text('Google Maps'),
                onTap: () {
                  Navigator.pop(context);
                  _launchExternalMap('https://www.google.com/maps/dir/?api=1&origin=$_userLocation?.latitude,$_userLocation?.longitude&destination=$lat,$lon');
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchExternalMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tanlangan navigator topilmadi")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosquesAsync = ref.watch(mosqueControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: _onMapCreated,
            mapObjects: _mapObjects,
            logoAlignment: const MapAlignment(horizontal: HorizontalAlignment.left, vertical: VerticalAlignment.bottom),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (Navigator.of(context).canPop())
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            widget.targetName ?? 'Masjid Qidirish',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 200,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: _moveToUser,
              child: Icon(Icons.my_location_rounded, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: mosquesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (mosques) {
                    if (mosques.isEmpty && widget.targetPoint == null) return const SizedBox.shrink();
                    
                    // Show target or nearest
                    final mosqueToShow = widget.targetPoint != null 
                      ? mosques.firstWhere((m) => m.latitude == widget.targetPoint!.latitude && m.longitude == widget.targetPoint!.longitude, orElse: () => mosques.first)
                      : mosques.first;

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(
                                  Icons.mosque_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mosqueToShow.name,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${mosqueToShow.distanceLabel} Left',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => MosqueDetailScreen(mosqueId: mosqueToShow.id)),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                                  onPressed: () {
                                    _buildRoute(Point(latitude: mosqueToShow.latitude, longitude: mosqueToShow.longitude));
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_isRouteActive) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showNavigationOptions(mosqueToShow.latitude, mosqueToShow.longitude),
                                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                    label: const Text("Tashqi xarita"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
