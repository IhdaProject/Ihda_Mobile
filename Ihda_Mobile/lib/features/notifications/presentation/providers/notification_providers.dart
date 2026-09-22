import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notification_data_source.dart';
import '../../data/datasources/real_notification_data_source.dart';
import '../../domain/entities/notification_settings.dart';

final _notificationsPluginProvider = Provider((ref) => FlutterLocalNotificationsPlugin());

final notificationDataSourceProvider = Provider<NotificationDataSource>((ref) {
  final plugin = ref.watch(_notificationsPluginProvider);
  return RealNotificationDataSource(plugin);
});

final notificationInitializerProvider = FutureProvider<void>((ref) async {
  final ds = ref.watch(notificationDataSourceProvider);
  if (ds is RealNotificationDataSource) {
    await ds.init();
  }
});

class NotificationSettingsNotifier extends StateNotifier<DetailedNotificationSettings> {
  NotificationSettingsNotifier() : super(const DetailedNotificationSettings());

  void toggleGlobal(bool enabled) {
    state = state.copyWith(globalEnabled: enabled);
  }

  void toggleMainPrayer(String id, bool enabled) {
    final updated = state.mainPrayers.map((p) {
      if (p.id == id) return p.copyWith(enabled: enabled);
      return p;
    }).toList();
    state = state.copyWith(mainPrayers: updated);
  }

  void setMainPrayerSound(String id, NotificationSoundType sound, {String? customAudioName}) {
    final updated = state.mainPrayers.map((p) {
      if (p.id == id) {
        return p.copyWith(
          sound: sound,
          customAudioName: customAudioName ?? p.customAudioName,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(mainPrayers: updated);
  }

  void setMainPrayerOffset(String id, int offsetMinutes) {
    final updated = state.mainPrayers.map((p) {
      if (p.id == id) return p.copyWith(offsetMinutes: offsetMinutes);
      return p;
    }).toList();
    state = state.copyWith(mainPrayers: updated);
  }

  void toggleNaflPrayer(String id, bool enabled) {
    final updated = state.naflPrayers.map((p) {
      if (p.id == id) return p.copyWith(enabled: enabled);
      return p;
    }).toList();
    state = state.copyWith(naflPrayers: updated);
  }

  void setNaflPrayerSound(String id, NotificationSoundType sound, {String? customAudioName}) {
    final updated = state.naflPrayers.map((p) {
      if (p.id == id) {
        return p.copyWith(
          sound: sound,
          customAudioName: customAudioName ?? p.customAudioName,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(naflPrayers: updated);
  }

  void setNaflPrayerOffset(String id, int offsetMinutes) {
    final updated = state.naflPrayers.map((p) {
      if (p.id == id) return p.copyWith(offsetMinutes: offsetMinutes);
      return p;
    }).toList();
    state = state.copyWith(naflPrayers: updated);
  }

  void toggleAppNews(bool enabled) {
    state = state.copyWith(appNewsEnabled: enabled);
  }

  void toggleCommunityPosts(bool enabled) {
    state = state.copyWith(communityPostsEnabled: enabled);
  }
}

final detailedNotificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, DetailedNotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});
