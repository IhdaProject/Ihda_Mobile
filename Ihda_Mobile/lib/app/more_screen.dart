import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/localization/localization_provider.dart';
import '../features/feed/domain/entities/feed_item.dart';
import '../features/feed/presentation/screens/community_screen.dart';
import '../features/feed/presentation/screens/hadith_duas_screen.dart';
import '../features/important_dates/presentation/screens/important_dates_screen.dart';
import '../features/location/presentation/screens/region_selection_screen.dart';
import '../features/qazo/presentation/screens/qazo_screen.dart';
import '../features/qibla/presentation/screens/qibla_screen.dart';
import '../features/quiz/presentation/screens/quiz_question_screen.dart';
import '../features/quran_courses/presentation/screens/quran_courses_screen.dart';
import '../features/tasbih/presentation/screens/tasbih_screen.dart';
import '../shared/widgets/design_background.dart';
import '../shared/widgets/not_ready_screen.dart';
import 'theme/app_spacing.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final gridRatio = fontScale > 1.1 ? 0.72 : 0.82;

    // Item sequence matches HomeScreen quick actions 100% in exact order!
    final items = <_MoreItem>[
      _MoreItem(
        "Qur'on",
        Icons.menu_book_rounded,
        () => _push(context, const NotReadyScreen(title: "Qur'oni Karim", icon: Icons.menu_book_rounded)),
      ),
      _MoreItem(
        "Kurslar",
        Icons.school_rounded,
        () => _push(context, const QuranCoursesScreen()),
      ),
      _MoreItem(
        "Viktorina",
        Icons.quiz_rounded,
        () => _push(context, const QuizQuestionScreen()),
      ),
      _MoreItem(
        "Sanalar",
        Icons.event_available_rounded,
        () => _push(context, const ImportantDatesScreen()),
      ),
      _MoreItem(
        'hadith'.tr(ref),
        Icons.auto_stories_rounded,
        () => _push(context, const HadithDuasScreen(initialCategory: FeedCategory.hadith)),
      ),
      _MoreItem(
        'dua'.tr(ref),
        Icons.volunteer_activism_rounded,
        () => _push(context, const HadithDuasScreen(initialCategory: FeedCategory.dua)),
      ),
      _MoreItem(
        'verse'.tr(ref),
        Icons.format_quote_rounded,
        () => _push(context, const HadithDuasScreen(initialCategory: FeedCategory.verse)),
      ),
      _MoreItem(
        'tasbih'.tr(ref),
        Icons.touch_app_rounded,
        () => _push(context, const TasbihScreen()),
      ),
      _MoreItem(
        'qibla'.tr(ref),
        Icons.explore_rounded,
        () => _push(context, const QiblaScreen()),
      ),
      _MoreItem(
        'Taqvim',
        Icons.calendar_month_rounded,
        () => _push(context, const RegionSelectionScreen()),
      ),
      _MoreItem(
        'qazo'.tr(ref),
        Icons.event_repeat_rounded,
        () => _push(context, const QazoScreen()),
      ),
      _MoreItem(
        'community'.tr(ref),
        Icons.groups_rounded,
        () => _push(context, const CommunityScreen()),
      ),
      _MoreItem(
        'Islom.uz',
        Icons.public_rounded,
        () => _openLink(context, 'https://islom.uz'),
      ),
      _MoreItem(
        'Radio',
        Icons.radio_rounded,
        () => _push(context, const NotReadyScreen(title: 'Islomiy Radio', icon: Icons.radio_rounded)),
      ),
    ];

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'more'.tr(ref),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.xs,
                    crossAxisSpacing: AppSpacing.xs,
                    childAspectRatio: gridRatio,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _MoreTile(item: items[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  static Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

class _MoreItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MoreItem(this.label, this.icon, this.onTap);
}

class _MoreTile extends StatelessWidget {
  final _MoreItem item;

  const _MoreTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);
    final boxSize = max(44.0, 44.0 * fontScale);

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: Theme.of(context).colorScheme.primary, size: 22 * fontScale),
          ),
          const SizedBox(height: 1),
          Text(
            item.label,
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
