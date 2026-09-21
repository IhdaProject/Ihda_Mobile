import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/mosques/presentation/screens/favorites_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/prayer_times/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import 'more_screen.dart';
import 'theme/app_colors.dart';
import '../core/localization/localization_provider.dart';
import 'providers/navigation_provider.dart';
import '../features/notifications/presentation/providers/notification_scheduler.dart';

/// Owns bottom-nav state and hosts the five top-level screens, matching the
/// real app's tab bar: Asosiy (Home), Sevimlilar (Favorites), Joylashuv (Map), 
/// Boshqalar (More), Profil (Profile).
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    HomeScreen(),
    FavoritesScreen(),
    MapScreen(),
    MoreScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep notification scheduler alive
    ref.watch(notificationSchedulerProvider);

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
