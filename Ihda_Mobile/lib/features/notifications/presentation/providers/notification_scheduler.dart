import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prayer_times/domain/entities/prayer.dart';
import '../../../prayer_times/domain/entities/prayer_day.dart';
import '../../../prayer_times/presentation/providers/prayer_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import 'notification_providers.dart';

/// Watches today's prayer times and settings, and schedules notifications accordingly.
final notificationSchedulerProvider = Provider.autoDispose<void>((ref) {
  // Ensure initialized
  ref.watch(notificationInitializerProvider);
  
  final settingsAsync = ref.watch(settingsControllerProvider);
  final prayerDayAsync = ref.watch(todayPrayerDayProvider);
  final dataSource = ref.watch(notificationDataSourceProvider);

  if (settingsAsync.hasValue && prayerDayAsync.hasValue) {
    final settings = settingsAsync.value!;
    final day = prayerDayAsync.value!;

    // Cancel all first to avoid duplicates or orphaned notifications
    dataSource.cancelAll().then((_) {
      if (!settings.notificationsEnabled) return;

      for (final prayer in day.prayers) {
        if (prayer.type.isNotifiable && !settings.mutedPrayers.contains(prayer.type)) {
          dataSource.scheduleForPrayer(prayer.type, prayer.time);
        }
      }
    });
  }
});
