import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../providers/mosque_providers.dart';
import '../widgets/mosque_grid_tile.dart';
import 'mosque_detail_screen.dart';

import '../../../../shared/widgets/design_background.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteMosquesProvider);
    final controller = ref.read(mosqueControllerProvider.notifier);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Sevimlilar',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Masjid Qidirish', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: favoritesAsync.when(
                  loading: () => const LoadingView(),
                  error: (e, _) => ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(mosqueControllerProvider),
                  ),
                  data: (mosques) {
                    if (mosques.isEmpty) {
                      return const EmptyView(
                        message: 'Hali sevimli masjidlar yo\'q. Masjid kartasidagi yulduzcha belgisini bosing.',
                        icon: Icons.star_border_rounded,
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: mosques.length,
                      itemBuilder: (context, index) {
                        final mosque = mosques[index];
                        return MosqueGridTile(
                          mosque: mosque,
                          onToggleFavorite: () => controller.toggleFavorite(mosque.id),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MosqueDetailScreen(mosqueId: mosque.id)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
