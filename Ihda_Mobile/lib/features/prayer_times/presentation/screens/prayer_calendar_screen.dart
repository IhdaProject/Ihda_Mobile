import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/prayer.dart';
import '../providers/prayer_providers.dart';
import '../widgets/prayer_time_tile.dart';

class PrayerCalendarScreen extends ConsumerStatefulWidget {
  const PrayerCalendarScreen({super.key});

  @override
  ConsumerState<PrayerCalendarScreen> createState() => _PrayerCalendarScreenState();
}

class _PrayerCalendarScreenState extends ConsumerState<PrayerCalendarScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _shift(int months) {
    setState(() => _month = DateTime(_month.year, _month.month + months, 1));
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(prayerCalendarProvider(_month));
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => _shift(-1),
          ),
          Text(DateFormat('MMM yyyy').format(_month), style: Theme.of(context).textTheme.bodyLarge),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => _shift(1),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: calendarAsync.when(
          loading: () => const LoadingView(message: 'Calculating month...'),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(prayerCalendarProvider(_month)),
          ),
          data: (days) {
            if (days.isEmpty) {
              return const EmptyView(message: 'No prayer times for this month.');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final day = days[index];
                final isToday = day.date.year == today.year &&
                    day.date.month == today.month &&
                    day.date.day == today.day;
                return AppCard(
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                    initiallyExpanded: isToday,
                    title: Row(
                      children: [
                        Text(
                          DateFormat('EEE, d MMM').format(day.date),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isToday ? Theme.of(context).colorScheme.primary : null,
                              ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    children: [
                      for (final prayer in day.prayers)
                        if (prayer.type != PrayerType.sunrise)
                          PrayerTimeTile(prayer: prayer),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
