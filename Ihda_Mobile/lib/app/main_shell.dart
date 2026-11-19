import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/mosques/presentation/screens/favorites_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/notifications/presentation/providers/notification_providers.dart';
import '../features/notifications/presentation/providers/notification_scheduler.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../features/prayer_times/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import 'more_screen.dart';
import 'theme/app_colors.dart';
import '../core/localization/localization_provider.dart';
import 'providers/navigation_provider.dart';

/// Owns bottom-nav state and hosts the five top-level screens, matching the
/// real app's tab bar: Asosiy (Home), Tanlanganlar (Favorites), Joylashuv (Map),
/// Boshqalar (More), Profil (Profile).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _screens = [
    HomeScreen(),
    FavoritesScreen(),
    MapScreen(),
    MoreScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotificationNavigation();
    });
  }

  void _initNotificationNavigation() async {
    final ds = ref.read(notificationDataSourceProvider);
    ds.setOnNotificationTap((route, payload) {
      _handleDeepLinkRoute(route, payload);
    });

    final initial = await ds.getInitialNotificationPayload();
    if (initial != null) {
      _handleDeepLinkRoute(initial['targetRoute'] ?? '/', initial['payload'] ?? '');
    }
  }

  void _handleDeepLinkRoute(String route, String payload) {
    if (!mounted) return;
    if (route == '/notification_settings' || route.contains('notification')) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
      );
    } else if (route == '/profile') {
      ref.read(navigationIndexProvider.notifier).state = 4;
    } else if (route == '/favorites') {
      ref.read(navigationIndexProvider.notifier).state = 1;
    } else if (route == '/map') {
      ref.read(navigationIndexProvider.notifier).state = 2;
    } else if (route == '/more') {
      ref.read(navigationIndexProvider.notifier).state = 3;
    } else {
      ref.read(navigationIndexProvider.notifier).state = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep offline notification scheduler and in-app realtime ticker alive
    ref.watch(notificationSchedulerProvider);
    ref.watch(inAppPrayerTickerProvider);

    final index = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => ref.read(navigationIndexProvider.notifier).state = i,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'home'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.star_border_rounded),
              selectedIcon: const Icon(Icons.star_rounded, color: AppColors.primary),
              label: 'favorites'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.location_on_outlined),
              selectedIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
              label: 'location'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
              label: 'more'.tr(ref),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'profile'.tr(ref),
            ),
          ],
        ),
      ),
    );
  }
}
