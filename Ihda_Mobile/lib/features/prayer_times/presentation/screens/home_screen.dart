import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/navigation_provider.dart';
import '../../../../app/providers/services_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_services.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../../shared/widgets/not_ready_screen.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../feed/domain/entities/feed_item.dart';
import '../../../feed/presentation/screens/community_screen.dart';
import '../../../feed/presentation/screens/hadith_duas_screen.dart';
import '../../../feed/presentation/screens/notifications_screen.dart';
import '../../../location/presentation/providers/location_providers.dart';
import '../../../location/presentation/screens/region_selection_screen.dart';
import '../../../important_dates/presentation/screens/important_dates_screen.dart';
import '../../../mosques/presentation/providers/mosque_providers.dart';
import '../../../mosques/presentation/screens/mosque_detail_screen.dart';
import '../../../mosques/presentation/widgets/mosque_card.dart';
import '../../../qazo/presentation/screens/qazo_screen.dart';
import '../../../qibla/presentation/screens/qibla_screen.dart';
import '../../../quiz/presentation/screens/quiz_question_screen.dart';
import '../../../quran_courses/presentation/screens/quran_courses_screen.dart';
import '../../../tasbih/presentation/screens/tasbih_screen.dart';
import '../providers/prayer_providers.dart';
import '../widgets/next_prayer_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() => _searchQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    final countdownAsync = ref.watch(prayerCountdownProvider);
    final locationAsync = ref.watch(currentLocationProvider);
    final mosquesAsync = ref.watch(mosqueControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final searchBarHeight = max(44.0, 44.0 * fontScale);

    final isSearchActive = _searchFocusNode.hasFocus || _searchQuery.isNotEmpty;

    final mosquesList = mosquesAsync.valueOrNull ?? [];
    final searchResults = mosquesList.where((m) {
      if (_searchQuery.isEmpty) return false;
      return m.name.toLowerCase().contains(_searchQuery) ||
          m.address.toLowerCase().contains(_searchQuery);
    }).toList();

    // Dropdown MUST ONLY open when there is an active search query AND at least 1 result match!
    final hasResultsToDisplay = _searchQuery.isNotEmpty && searchResults.isNotEmpty;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_searchFocusNode.hasFocus) {
            _searchFocusNode.unfocus();
          }
        },
        child: Stack(
          children: [
            // Background Content Layer (Always visible, unchanged position)
            Column(
              children: [
                HeroBackground(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header Row: Animated Expanding Search Bar & Fading Notification Button
                          Row(
                            children: [
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  height: searchBarHeight,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: hasResultsToDisplay
                                        ? (isDark
                                            ? Colors.black.withOpacity(0.55)
                                            : Colors.white.withOpacity(0.28))
                                        : Colors.white.withOpacity(0.25),
                                    borderRadius: hasResultsToDisplay
                                        ? const BorderRadius.vertical(top: Radius.circular(16))
                                        : BorderRadius.circular(AppRadius.pill),
                                    border: hasResultsToDisplay
                                        ? Border(
                                            top: BorderSide(color: Colors.white.withOpacity(0.35)),
                                            left: BorderSide(color: Colors.white.withOpacity(0.35)),
                                            right: BorderSide(color: Colors.white.withOpacity(0.35)),
                                            bottom: BorderSide.none,
                                          )
                                        : Border.all(color: Colors.white.withOpacity(0.35)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search_rounded, color: Colors.white, size: 20 * fontScale),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          cursorColor: Colors.white,
                                          decoration: InputDecoration(
                                            hintText: 'search'.tr(ref),
                                            hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                      if (_searchQuery.isNotEmpty || _searchFocusNode.hasFocus)
                                        GestureDetector(
                                          onTap: _clearSearch,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(Icons.clear_rounded, color: Colors.white, size: 18 * fontScale),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Spacing between Search Bar and Notification Button
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                width: isSearchActive ? 0 : AppSpacing.sm,
                              ),

                              // Fading & Collapsing Notification Button Container
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                width: isSearchActive ? 0 : searchBarHeight,
                                height: searchBarHeight,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isSearchActive ? 0.0 : 1.0,
                                  child: isSearchActive
                                      ? const SizedBox.shrink()
                                      : OverflowBox(
                                          maxWidth: searchBarHeight,
                                          maxHeight: searchBarHeight,
                                          child: _IconButtonBadge(
                                            icon: Icons.notifications_none_rounded,
                                            isWhite: true,
                                            size: searchBarHeight,
                                            onTap: () => Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Default Next Prayer Countdown Card with integrated Location & Calendar Tap
                          countdownAsync.when(
                            loading: () => const SizedBox(height: 180, child: LoadingView()),
                            error: (e, _) => ErrorView(
                              message: e.toString(),
                              onRetry: () => ref.invalidate(todayPrayerDayProvider),
                            ),
                            data: (countdown) => NextPrayerCard(
                              countdown: countdown,
                              cityName: locationAsync.valueOrNull?.city ?? 'Toshkent shahri',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegionSelectionScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Page Content Body (Edge-to-Edge horizontal scrolling & compact quick actions)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions Grid (Responsive & pulling from shared services)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final servicesState = ref.watch(servicesControllerProvider);
                              final allServices = ref.read(servicesControllerProvider.notifier).getOrderedServices();
                              final crossAxisCount = servicesState.columnCount; // 3 or 4
                              final maxSlots = (crossAxisCount * 2) - 1;
                              final displayedServices = allServices.take(maxSlots).toList();
                              final showMoreTile = maxSlots < allServices.length;
                              final totalTilesCount = displayedServices.length + (showMoreTile ? 1 : 0);

                              final gridRatio = fontScale > 1.1 ? 0.72 : 0.82;

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: AppSpacing.sm,
                                  crossAxisSpacing: AppSpacing.sm,
                                  childAspectRatio: gridRatio,
                                ),
                                itemCount: totalTilesCount,
                                itemBuilder: (context, index) {
                                  if (showMoreTile && index == totalTilesCount - 1) {
                                    return _QuickActionTile(
                                      icon: Icons.grid_view_rounded,
                                      label: 'more'.tr(ref),
                                      onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
                                    );
                                  }
                                  final service = displayedServices[index];
                                  return _ServiceTile(service: service);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Mosques Section Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text('mosques'.tr(ref), style: Theme.of(context).textTheme.titleLarge),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Edge-To-Edge Horizontal Mosques List
                        SizedBox(
                          height: 185 * fontScale,
                          child: mosquesAsync.when(
                            loading: () => const LoadingView(),
                            error: (e, _) => ErrorView(
                              message: e.toString(),
                              onRetry: () => ref.invalidate(mosqueControllerProvider),
                            ),
                            data: (mosques) => ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              scrollDirection: Axis.horizontal,
                              itemCount: mosques.length,
                              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final mosque = mosques[index];
                                return MosqueCard(
                                  mosque: mosque,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => MosqueDetailScreen(mosqueId: mosque.id)),
                                  ),
                                  onToggleFavorite: () =>
                                      ref.read(mosqueControllerProvider.notifier).toggleFavorite(mosque.id),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Seamless Glassmorphism Search Results Dropdown Layer (ONLY when results > 0)
            if (hasResultsToDisplay)
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.md + searchBarHeight,
                left: AppSpacing.md,
                right: AppSpacing.md, // Aligns 100% with full-width expanded search bar!
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(maxHeight: 280),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.55)
                        : Colors.white.withOpacity(0.28),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    border: Border(
                      left: BorderSide(color: Colors.white.withOpacity(0.35)),
                      right: BorderSide(color: Colors.white.withOpacity(0.35)),
                      bottom: BorderSide(color: Colors.white.withOpacity(0.35)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                        child: Text(
                          'Qidiruv natijalari (${searchResults.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          itemCount: searchResults.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final mosque = searchResults[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _clearSearch();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MosqueDetailScreen(mosqueId: mosque.id),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Theme.of(context).colorScheme.surface
                                        : Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.mosque_rounded,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 18 * fontScale,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              mosque.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              mosque.address,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? Colors.white60 : Colors.black54,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends ConsumerWidget {
  final ServiceItem service;

  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final boxSize = max(58.0, 58.0 * fontScale);
    final iconSize = 28.0 * fontScale;

    return InkWell(
      onTap: () => service.onTap(context, ref),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              service.icon,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.getLabel(ref),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final boxSize = max(58.0, 58.0 * fontScale);
    final iconSize = 28.0 * fontScale;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _IconButtonBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isWhite;
  final double size;

  const _IconButtonBadge({
    required this.icon,
    required this.onTap,
    this.isWhite = false,
    this.size = 44.0,
  });

  @override
  Widget cardBuilder(BuildContext context) => build(context);

  @override
  Widget build(BuildContext context) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isWhite ? Colors.white.withOpacity(0.25) : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: isWhite ? Border.all(color: Colors.white.withOpacity(0.35)) : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color: isWhite ? Colors.white : Theme.of(context).colorScheme.onSurface,
              size: 20 * fontScale,
            ),
          ),
        ),
      ),
    );
  }
}
