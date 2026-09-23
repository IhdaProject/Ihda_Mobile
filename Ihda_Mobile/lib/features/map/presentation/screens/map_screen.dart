import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../location/presentation/screens/region_selection_screen.dart';
import '../../../mosques/domain/entities/mosque.dart';
import '../../../mosques/presentation/providers/mosque_providers.dart';
import '../../../mosques/presentation/screens/mosque_detail_screen.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class SelectedMapTarget {
  final Point point;
  final String name;
  final String mosqueId;

  const SelectedMapTarget({
    required this.point,
    required this.name,
    required this.mosqueId,
  });
}

final selectedMapTargetProvider = StateProvider<SelectedMapTarget?>((ref) => null);

enum TransportMode { driving, transit, walking }

extension TransportModeX on TransportMode {
  String get label {
    switch (this) {
      case TransportMode.driving:
        return 'Mashinada';
      case TransportMode.transit:
        return 'Avtobusda';
      case TransportMode.walking:
        return 'Piyoda';
    }
  }

  IconData get icon {
    switch (this) {
      case TransportMode.driving:
        return Icons.directions_car_rounded;
      case TransportMode.transit:
        return Icons.directions_bus_rounded;
      case TransportMode.walking:
        return Icons.directions_walk_rounded;
    }
  }
}

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
  final TextEditingController _searchController = TextEditingController();
  
  Point? _userLocation;
  Mosque? _selectedMosque;
  TransportMode _selectedTransport = TransportMode.driving;
  bool _isLiveNavigating = false;
  String _searchQuery = '';
  Timer? _liveNavTimer;

  static const Point _tashkentDefault = Point(latitude: 41.2995, longitude: 69.2401);

  bool get _isMobilePlatform =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _liveNavTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissionAndInit() async {
    if (_isMobilePlatform) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        try {
          final pos = await Geolocator.getCurrentPosition();
          _userLocation = Point(latitude: pos.latitude, longitude: pos.longitude);
        } catch (_) {
          _userLocation = _tashkentDefault;
        }
      } else {
        _userLocation = _tashkentDefault;
      }
    } else {
      _userLocation = _tashkentDefault;
    }

    _updateMarkersAndSelectTarget();
  }

  void _moveToUser() {
    final point = _userLocation ?? _tashkentDefault;
    _moveToPoint(point);
    showAppToast(context, 'Hozirgi joylashuvingizga o\'tildi', icon: Icons.my_location_rounded);
  }

  void _moveToPoint(Point point) {
    if (_isMobilePlatform) {
      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: point, zoom: 15),
        ),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
      );
    }
  }

  void _onMapCreated(YandexMapController controller) {
    _mapController = controller;
    _updateMarkersAndSelectTarget();
  }

  void _updateMarkersAndSelectTarget() {
    final mosques = ref.read(mosqueControllerProvider).valueOrNull ?? [];
    final targetFromProvider = ref.read(selectedMapTargetProvider);
    final effectiveTargetPoint = widget.targetPoint ?? targetFromProvider?.point;
    final effectiveTargetName = widget.targetName ?? targetFromProvider?.name;
    
    setState(() {
      _mapObjects.removeWhere((obj) => obj.mapId.value.startsWith('mosque_') || obj.mapId.value == 'user_location');

      final userPoint = _userLocation ?? _tashkentDefault;
      // User Marker
      _mapObjects.add(
        PlacemarkMapObject(
          mapId: const MapObjectId('user_location'),
          point: userPoint,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/app_icon.png'),
              scale: 0.12,
            ),
          ),
        ),
      );

      // Nearby Mosques Markers
      for (final mosque in mosques) {
        _mapObjects.add(
          PlacemarkMapObject(
            mapId: MapObjectId('mosque_${mosque.id}'),
            point: Point(latitude: mosque.latitude, longitude: mosque.longitude),
            onTap: (object, point) {
              _selectMosque(mosque);
            },
          ),
        );
      }

      // Auto-select target if navigated from Mosque Detail Screen or Provider
      if (effectiveTargetPoint != null && _selectedMosque == null) {
        final matched = mosques.firstWhere(
          (m) => m.latitude == effectiveTargetPoint.latitude && m.longitude == effectiveTargetPoint.longitude,
          orElse: () => Mosque(
            id: targetFromProvider?.mosqueId ?? 'target',
            name: effectiveTargetName ?? 'Tanlangan Masjid',
            address: 'Manzil',
            phone: '+998',
            distanceLabel: '2.4 km',
            latitude: effectiveTargetPoint.latitude,
            longitude: effectiveTargetPoint.longitude,
          ),
        );
        _selectedMosque = matched;
        _buildRouteToPoint(effectiveTargetPoint);
        _moveToPoint(effectiveTargetPoint);

        if (targetFromProvider != null) {
          Future.microtask(() {
            ref.read(selectedMapTargetProvider.notifier).state = null;
          });
        }
      } else if (_selectedMosque == null) {
        _moveToPoint(userPoint);
      }
    });
  }

  void _selectMosque(Mosque mosque) {
    setState(() {
      _selectedMosque = mosque;
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
    _moveToPoint(Point(latitude: mosque.latitude, longitude: mosque.longitude));
    _buildRouteToPoint(Point(latitude: mosque.latitude, longitude: mosque.longitude));
  }

  void _buildRouteToPoint(Point target) {
    final start = _userLocation ?? _tashkentDefault;
    
    final routePolyline = PolylineMapObject(
      mapId: const MapObjectId('route_polyline'),
      polyline: Polyline(points: [start, target]),
      strokeColor: AppColors.primary,
      strokeWidth: 5,
      dashLength: _selectedTransport == TransportMode.walking ? 8 : 0,
      gapLength: _selectedTransport == TransportMode.walking ? 4 : 0,
    );

    setState(() {
      _mapObjects.removeWhere((obj) => obj.mapId.value == 'route_polyline');
      _mapObjects.add(routePolyline);
    });
  }

  void _startInAppNavigation() {
    if (_selectedMosque == null) return;
    setState(() => _isLiveNavigating = true);
    
    showAppToast(context, 'Ilova ichida navigatsiya boshlandi', icon: Icons.navigation_rounded);
    
    _liveNavTimer?.cancel();
    _liveNavTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isLiveNavigating) {
        timer.cancel();
        return;
      }
      showAppToast(context, "Harakatlanmoqdasiz... To'g'ri davom eting", icon: Icons.navigation_rounded);
    });
  }

  void _stopInAppNavigation() {
    _liveNavTimer?.cancel();
    setState(() => _isLiveNavigating = false);
    showAppToast(context, 'Navigatsiya yakunlandi', icon: Icons.stop_circle_rounded);
  }

  void _showNavigationOptions(Mosque mosque) {
    final lat = mosque.latitude;
    final lon = mosque.longitude;
    final start = _userLocation ?? _tashkentDefault;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${mosque.name} ga yo\'nalish',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  child: Icon(Icons.navigation_rounded, color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('Ilova ichida navigatsiya', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Ilovadan chiqmasdan xaritada harakatlaning'),
                trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                onTap: () {
                  Navigator.pop(context);
                  _startInAppNavigation();
                },
              ),
              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.map_rounded, color: Colors.red),
                title: const Text('Yandex Navigator / Maps'),
                subtitle: const Text('Tashqi ilovada ochish'),
                onTap: () {
                  Navigator.pop(context);
                  _launchExternalMap('yandexmaps://maps.yandex.ru/?rtext=${start.latitude},${start.longitude}~$lat,$lon&rtt=auto');
                },
              ),
              ListTile(
                leading: const Icon(Icons.pin_drop_rounded, color: Colors.blue),
                title: const Text('Google Maps'),
                subtitle: const Text('Tashqi ilovada ochish'),
                onTap: () {
                  Navigator.pop(context);
                  _launchExternalMap('https://www.google.com/maps/dir/?api=1&origin=${start.latitude},${start.longitude}&destination=$lat,$lon');
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore_rounded, color: Colors.green),
                title: const Text('2GIS / Apple Maps'),
                subtitle: const Text('Tashqi ilovada ochish'),
                onTap: () {
                  Navigator.pop(context);
                  _launchExternalMap('dgis://2gis.ru/routeSearch/rs/from/${start.longitude},${start.latitude}/to/$lon,$lat');
                },
              ),
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
      showAppToast(context, 'Tashqi xarita ilovasi topilmadi', icon: Icons.error_outline_rounded);
    }
  }

  String _getEstimateLabel() {
    switch (_selectedTransport) {
      case TransportMode.driving:
        return '🚗 8 daqiqa (2.4 km)';
      case TransportMode.transit:
        return '🚌 15 daqiqa (2.4 km)';
      case TransportMode.walking:
        return '🚶 24 daqiqa (2.4 km)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosquesAsync = ref.watch(mosqueControllerProvider);
    final mosquesList = mosquesAsync.valueOrNull ?? [];

    final filteredSearch = mosquesList.where((m) {
      if (_searchQuery.isEmpty) return false;
      return m.name.toLowerCase().contains(_searchQuery) ||
          m.address.toLowerCase().contains(_searchQuery);
    }).toList();

    final cardBgColor = Theme.of(context).colorScheme.surface;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Map View (Native Yandex Map on Android/iOS; Fallback Design on Web/Desktop)
          if (_isMobilePlatform)
            YandexMap(
              onMapCreated: _onMapCreated,
              mapObjects: _mapObjects,
              logoAlignment: const MapAlignment(horizontal: HorizontalAlignment.left, vertical: VerticalAlignment.bottom),
            )
          else
            DesignBackground(
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_rounded, size: 72, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Interaktiv Xarita',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mobil ilovada Yandex Vektor xaritasi to\'liq ishlaydi',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardBgColor.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Masjidlarni nom bo\'yicha qidirish...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  // Search Suggestions Dropdown
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Card(
                      elevation: 4,
                      color: cardBgColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Column(
                        children: [
                          if (filteredSearch.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Text('Masjid topilmadi', style: TextStyle(color: Colors.grey)),
                            )
                          else
                            for (final mosque in filteredSearch)
                              ListTile(
                                leading: Icon(Icons.mosque_rounded, color: Theme.of(context).colorScheme.primary),
                                title: Text(mosque.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(mosque.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                                onTap: () => _selectMosque(mosque),
                              ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // GPS My Location Floating Button
          Positioned(
            right: 16,
            bottom: _selectedMosque != null ? 240 : 100,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: cardBgColor,
              onPressed: _moveToUser,
              child: Icon(Icons.my_location_rounded, color: Theme.of(context).colorScheme.primary),
            ),
          ),

          // Live Navigation Active Status Banner
          if (_isLiveNavigating)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Card(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedMosque?.name} ga harakatlanmoqdasiz',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _getEstimateLabel(),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: _stopInAppNavigation,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Selected Mosque Card
          if (_selectedMosque != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.mosque_rounded, color: Theme.of(context).colorScheme.primary, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedMosque!.name,
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getEstimateLabel(),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => MosqueDetailScreen(mosqueId: _selectedMosque!.id)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.grey),
                              onPressed: () => setState(() {
                                _selectedMosque = null;
                                _mapObjects.removeWhere((obj) => obj.mapId.value == 'route_polyline');
                              }),
                            ),
                          ],
                        ),
                        const Divider(height: 16),

                        // Transport Modes Selector (Mashinada, Avtobusda, Piyoda)
                        Row(
                          children: [
                            for (final mode in TransportMode.values) ...[
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedTransport = mode;
                                    });
                                    if (_selectedMosque != null) {
                                      _buildRouteToPoint(Point(latitude: _selectedMosque!.latitude, longitude: _selectedMosque!.longitude));
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _selectedTransport == mode
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedTransport == mode
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          mode.icon,
                                          size: 16,
                                          color: _selectedTransport == mode
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          mode.label,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedTransport == mode
                                                ? Theme.of(context).colorScheme.primary
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (mode != TransportMode.walking) const SizedBox(width: 6),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Main Navigation Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showNavigationOptions(_selectedMosque!),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.navigation_rounded),
                            label: const Text('Yo\'nalishni boshlash'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
