import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/localization/localization_provider.dart';
import '../features/feed/domain/entities/feed_item.dart';
import '../features/feed/presentation/screens/community_screen.dart';
import '../features/feed/presentation/screens/hadith_duas_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/prayer_times/presentation/screens/prayer_calendar_screen.dart';
import '../features/qazo/presentation/screens/qazo_screen.dart';
import '../features/qibla/presentation/screens/qibla_screen.dart';
import '../features/tasbih/presentation/screens/tasbih_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';

import '../shared/widgets/design_background.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <_MoreItem>[
      _MoreItem('hadith'.tr(ref), Icons.menu_book_rounded,
          () => _push(context, const HadithDuasScreen(initialCategory: FeedCategory.hadith))),
      _MoreItem('dua'.tr(ref), Icons.volunteer_activism_rounded,
          () => _push(context, const HadithDuasScreen(initialCategory: FeedCategory.dua))),
      _MoreItem('verse'.tr(ref), Icons.auto_stories_rounded,
          () => _push(context, const HadithDuasScreen(initialCategory: FeedCategory.verse))),
      _MoreItem('community'.tr(ref), Icons.groups_rounded, () => _push(context, const CommunityScreen())),
      _MoreItem('tasbih'.tr(ref), Icons.track_changes_rounded, () => _push(context, const TasbihScreen())),
      _MoreItem('qazo'.tr(ref), Icons.event_repeat_rounded, () => _push(context, const QazoScreen())),
      _MoreItem('qibla'.tr(ref), Icons.explore_rounded, () => _push(context, const QiblaScreen())),
      _MoreItem('Taqvim', Icons.calendar_month_rounded, () => _push(context, const PrayerCalendarScreen())),
      _MoreItem('Islom.uz', Icons.public_rounded, () => _openLink(context, 'https://islom.uz')),
      _MoreItem('Radio', Icons.radio_rounded,
          () => _snack(context, 'Radio - keyinroq ulanadi')),
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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.9,
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

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack(context, "Havolani ochib bo'lmadi");
    }
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
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
