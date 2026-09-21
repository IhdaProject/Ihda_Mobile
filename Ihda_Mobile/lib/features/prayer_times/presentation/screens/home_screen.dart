import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../feed/domain/entities/feed_item.dart';
import '../../../feed/presentation/screens/community_screen.dart';
import '../../../feed/presentation/screens/hadith_duas_screen.dart';
import '../../../feed/presentation/screens/notifications_screen.dart';
import '../../../location/presentation/providers/location_providers.dart';
import '../../../mosques/presentation/providers/mosque_providers.dart';
import '../../../mosques/presentation/screens/mosque_detail_screen.dart';
import '../../../mosques/presentation/widgets/mosque_card.dart';
import '../../../qazo/presentation/screens/qazo_screen.dart';
import '../../../qibla/presentation/screens/qibla_screen.dart';
import '../../../tasbih/presentation/screens/tasbih_screen.dart';
import '../../../map/presentation/screens/map_screen.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart' as yandex;
import '../providers/prayer_providers.dart';
import '../widgets/next_prayer_card.dart';
import '../../../../app/providers/navigation_provider.dart';

import '../../../../shared/widgets/design_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdownAsync = ref.watch(prayerCountdownProvider);
    final locationAsync = ref.watch(currentLocationProvider);
    final mosquesAsync = ref.watch(mosqueControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          HeroBackground(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'search'.tr(ref),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
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
                    const SizedBox(height: AppSpacing.md),
                    countdownAsync.when(
                      loading: () => const SizedBox(height: 180, child: LoadingView()),
                      error: (e, _) => ErrorView(
                        message: e.toString(),
                        onRetry: () => ref.invalidate(todayPrayerDayProvider),
                      ),
                      data: (countdown) => NextPrayerCard(countdown: countdown),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Sizning joylashuvingiz',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(width: 4),
                      locationAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (loc) => Text(
                          '- ${loc.city}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                            icon: Icons.auto_stories_rounded,
                            label: 'verse'.tr(ref),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HadithDuasScreen(initialCategory: FeedCategory.verse),
                              ),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.track_changes_rounded,
                            label: 'tasbih'.tr(ref),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TasbihScreen()),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.event_repeat_rounded,
                            label: 'qazo'.tr(ref),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => QazoScreen()),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.explore_rounded,
                            label: 'qibla'.tr(ref),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => QiblaScreen()),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.groups_rounded,
                            label: 'community'.tr(ref),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CommunityScreen()),
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
