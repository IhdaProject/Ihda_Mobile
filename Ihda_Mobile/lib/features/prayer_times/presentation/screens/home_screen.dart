import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/navigation_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
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
import '../../../mosques/presentation/providers/mosque_providers.dart';
import '../../../mosques/presentation/screens/mosque_detail_screen.dart';
import '../../../mosques/presentation/widgets/mosque_card.dart';
import '../../../qazo/presentation/screens/qazo_screen.dart';
import '../../../qibla/presentation/screens/qibla_screen.dart';
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
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _isSearching = _searchFocusNode.hasFocus || _searchQuery.isNotEmpty;
      });
    });
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus || _searchQuery.isNotEmpty;
      });
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
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final countdownAsync = ref.watch(prayerCountdownProvider);
    final locationAsync = ref.watch(currentLocationProvider);
    final mosquesAsync = ref.watch(mosqueControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mosquesList = mosquesAsync.valueOrNull ?? [];
    final searchResults = mosquesList.where((m) {
      if (_searchQuery.isEmpty) return true;
      return m.name.toLowerCase().contains(_searchQuery) ||
          m.address.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_searchFocusNode.hasFocus && _searchQuery.isEmpty) {
            _searchFocusNode.unfocus();
          }
        },
        child: Column(
          children: [
            // Hero Background Header with Attached Semi-Transparent Search Dropdown
            HeroBackground(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar & Notification Badge
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: _isSearching
                                    ? const BorderRadius.vertical(top: Radius.circular(20))
                                    : BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: Colors.white.withOpacity(0.35)),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'search'.tr(ref),
                                  hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                                  suffixIcon: _searchQuery.isNotEmpty || _searchFocusNode.hasFocus
                                      ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, color: Colors.white, size: 18),
                                    onPressed: _clearSearch,
                                  )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _IconButtonBadge(
                            icon: Icons.notifications_none_rounded,
                            isWhite: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                            ),
                          ),
                        ],
                      ),

                      // Attached Glassmorphism Search Results Box Directly Under Search Bar
                      if (_isSearching) ...[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          constraints: const BoxConstraints(maxHeight: 220),
                          margin: const EdgeInsets.only(right: 56), // Align with search bar
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withOpacity(0.55)
                                : Colors.white.withOpacity(0.35),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  _searchQuery.isEmpty ? 'Masjidlarni qidirish...' : 'Qidiruv natijalari',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: searchResults.isEmpty
                                    ? const Center(
                                  child: Text(
                                    'Masjid topilmadi',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                )
                                    : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: searchResults.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                                  itemBuilder: (context, index) {
                                    final mosque = searchResults[index];
                                    return Card(
                                      margin: EdgeInsets.zero,
                                      color: isDark
                                          ? Theme.of(context).colorScheme.surface
                                          : Colors.white.withOpacity(0.95),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                        leading: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.mosque_rounded, color: Theme.of(context).colorScheme.primary, size: 18),
                                        ),
                                        title: Text(
                                          mosque.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        subtitle: Text(
                                          mosque.address,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          _clearSearch();
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => MosqueDetailScreen(mosqueId: mosque.id)),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: AppSpacing.md),
                        // Default Next Prayer Countdown Card
                        countdownAsync.when(
                          loading: () => const SizedBox(height: 180, child: LoadingView()),
                          error: (e, _) => ErrorView(
                            message: e.toString(),
                            onRetry: () => ref.invalidate(todayPrayerDayProvider),
                          ),
                          data: (countdown) => NextPrayerCard(countdown: countdown),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Page Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Region / Location Selection Row
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegionSelectionScreen()),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Row(
                          children: [
                            Icon(Icons.place_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Joylashuv:',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: locationAsync.when(
                                loading: () => const Text('Yuklanmoqda...'),
                                error: (_, __) => const Text('Toshkent shahri'),
                                data: (loc) => Text(
                                  loc.city,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Quick Actions Grid (Exact Requested Order: Quron, Hadis, Duo, Kun oyati, Tasbeh, Qibla, Taqvim, Boshqalar)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          mainAxisSpacing: AppSpacing.sm,
                          crossAxisSpacing: AppSpacing.xs,
                          childAspectRatio: 0.85,
                          children: [
                            _QuickAction(
                              icon: Icons.menu_book_rounded,
                              label: "Qur'on",
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotReadyScreen(title: "Qur'oni Karim", icon: Icons.menu_book_rounded),
                                ),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.auto_stories_rounded,
                              label: 'hadith'.tr(ref),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HadithDuasScreen(initialCategory: FeedCategory.hadith),
                                ),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.volunteer_activism_rounded,
                              label: 'dua'.tr(ref),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HadithDuasScreen(initialCategory: FeedCategory.dua),
                                ),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.format_quote_rounded,
                              label: 'verse'.tr(ref),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HadithDuasScreen(initialCategory: FeedCategory.verse),
                                ),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.touch_app_rounded,
                              label: 'tasbih'.tr(ref),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TasbihScreen()),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.explore_rounded,
                              label: 'qibla'.tr(ref),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const QiblaScreen()),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.calendar_month_rounded,
                              label: 'Taqvim',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegionSelectionScreen()),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.grid_view_rounded,
                              label: 'more'.tr(ref),
                              onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text('mosques'.tr(ref), style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 185,
                      child: mosquesAsync.when(
                        loading: () => const LoadingView(),
                        error: (e, _) => ErrorView(
                          message: e.toString(),
                          onRetry: () => ref.invalidate(mosqueControllerProvider),
                        ),
                        data: (mosques) => ListView.separated(
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
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
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

  const _IconButtonBadge({required this.icon, required this.onTap, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isWhite ? Colors.white.withOpacity(0.2) : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Icon(
          icon,
          color: isWhite ? Colors.white : Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }
}
