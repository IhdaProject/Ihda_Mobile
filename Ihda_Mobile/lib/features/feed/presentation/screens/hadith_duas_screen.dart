import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/feed_item.dart';
import '../providers/feed_providers.dart';
import '../widgets/post_card.dart';

import '../../../../shared/widgets/design_background.dart';

/// Shows Hadith, Dua, or Verse-of-the-day content depending on [initialCategory].
class HadithDuasScreen extends ConsumerWidget {
  final FeedCategory initialCategory;

  const HadithDuasScreen({super.key, this.initialCategory = FeedCategory.hadith});

  String get _title {
    switch (initialCategory) {
      case FeedCategory.dua:
        return 'Duolar';
      case FeedCategory.verse:
        return 'Kundalik oyat';
      default:
        return 'Hadith & Dua';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedByCategoryProvider(initialCategory));

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
                        _title,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: feedAsync.when(
                  loading: () => const LoadingView(),
                  error: (e, _) => ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(feedByCategoryProvider(initialCategory)),
                  ),
                  data: (items) => ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                    children: [
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Center(
                          child: Icon(Icons.mosque_rounded, size: 48, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final item in items) ...[
                        PostCard(item: item),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
