import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  NotificationSettingsNotifier() : super(const DetailedNotificationSettings()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final global = prefs.getBool('notif_global_enabled') ?? true;

      final mainPrayers = state.mainPrayers.map((p) {
        final enabled = prefs.getBool('notif_main_${p.id}_enabled') ?? p.enabled;
        final soundKeyStr = prefs.getString('notif_main_${p.id}_sound_key');
        final soundIndex = prefs.getInt('notif_main_${p.id}_sound');
        final sound = soundKeyStr != null
            ? NotificationSoundTypeX.fromKey(soundKeyStr)
            : (soundIndex != null
                ? NotificationSoundType.values[soundIndex.clamp(0, NotificationSoundType.values.length - 1)]
                : p.sound);

        final customAudio = prefs.getString('notif_main_${p.id}_audio') ?? p.customAudioName;
        final offsetSecs = prefs.getInt('notif_main_${p.id}_offset_seconds') ??
            (prefs.getInt('notif_main_${p.id}_offset') != null
                ? prefs.getInt('notif_main_${p.id}_offset')! * 60
                : p.offsetSeconds);

        final titleTpl = prefs.getString('notif_main_${p.id}_title_tpl') ?? p.titleTemplate;
        final bodyTpl = prefs.getString('notif_main_${p.id}_body_tpl') ?? p.bodyTemplate;
        final route = prefs.getString('notif_main_${p.id}_route') ?? p.targetRoute;

        return p.copyWith(
          enabled: enabled,
          sound: sound,
          customAudioName: customAudio,
          offsetSeconds: offsetSecs,
          titleTemplate: titleTpl,
          bodyTemplate: bodyTpl,
          targetRoute: route,
        );
      }).toList();

      final naflPrayers = state.naflPrayers.map((p) {
        final enabled = prefs.getBool('notif_nafl_${p.id}_enabled') ?? p.enabled;
        final soundKeyStr = prefs.getString('notif_nafl_${p.id}_sound_key');
        final soundIndex = prefs.getInt('notif_nafl_${p.id}_sound');
        final sound = soundKeyStr != null
            ? NotificationSoundTypeX.fromKey(soundKeyStr)
            : (soundIndex != null
                ? NotificationSoundType.values[soundIndex.clamp(0, NotificationSoundType.values.length - 1)]
                : p.sound);

        final customAudio = prefs.getString('notif_nafl_${p.id}_audio') ?? p.customAudioName;
        final offsetSecs = prefs.getInt('notif_nafl_${p.id}_offset_seconds') ??
            (prefs.getInt('notif_nafl_${p.id}_offset') != null
                ? prefs.getInt('notif_nafl_${p.id}_offset')! * 60
                : p.offsetSeconds);

        final titleTpl = prefs.getString('notif_nafl_${p.id}_title_tpl') ?? p.titleTemplate;
        final bodyTpl = prefs.getString('notif_nafl_${p.id}_body_tpl') ?? p.bodyTemplate;
        final route = prefs.getString('notif_nafl_${p.id}_route') ?? p.targetRoute;

        return p.copyWith(
          enabled: enabled,
          sound: sound,
          customAudioName: customAudio,
          offsetSeconds: offsetSecs,
          titleTemplate: titleTpl,
          bodyTemplate: bodyTpl,
          targetRoute: route,
        );
      }).toList();

      state = state.copyWith(
        globalEnabled: global,
        mainPrayers: mainPrayers,
        naflPrayers: naflPrayers,
      );
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_global_enabled', state.globalEnabled);

      for (final p in state.mainPrayers) {
        await prefs.setBool('notif_main_${p.id}_enabled', p.enabled);
        await prefs.setString('notif_main_${p.id}_sound_key', p.sound.key);
        await prefs.setInt('notif_main_${p.id}_sound', p.sound.index);
        if (p.customAudioName != null) {
          await prefs.setString('notif_main_${p.id}_audio', p.customAudioName!);
        }
        await prefs.setInt('notif_main_${p.id}_offset_seconds', p.offsetSeconds);
        await prefs.setInt('notif_main_${p.id}_offset', p.offsetMinutes);
        if (p.titleTemplate != null) {
          await prefs.setString('notif_main_${p.id}_title_tpl', p.titleTemplate!);
        }
        if (p.bodyTemplate != null) {
          await prefs.setString('notif_main_${p.id}_body_tpl', p.bodyTemplate!);
        }
        await prefs.setString('notif_main_${p.id}_route', p.targetRoute);
      }

      for (final p in state.naflPrayers) {
        await prefs.setBool('notif_nafl_${p.id}_enabled', p.enabled);
        await prefs.setString('notif_nafl_${p.id}_sound_key', p.sound.key);
        await prefs.setInt('notif_nafl_${p.id}_sound', p.sound.index);
        if (p.customAudioName != null) {
          await prefs.setString('notif_nafl_${p.id}_audio', p.customAudioName!);
        }
        await prefs.setInt('notif_nafl_${p.id}_offset_seconds', p.offsetSeconds);
        await prefs.setInt('notif_nafl_${p.id}_offset', p.offsetMinutes);
        if (p.titleTemplate != null) {
          await prefs.setString('notif_nafl_${p.id}_title_tpl', p.titleTemplate!);
        }
        if (p.bodyTemplate != null) {
          await prefs.setString('notif_nafl_${p.id}_body_tpl', p.bodyTemplate!);
        }
        await prefs.setString('notif_nafl_${p.id}_route', p.targetRoute);
      }
    } catch (_) {}
  }

  void toggleGlobal(bool enabled) {
    state = state.copyWith(globalEnabled: enabled);
    _saveToPrefs();
  }

  void toggleMainPrayer(String id, bool enabled) {
    final updated = state.mainPrayers.map((p) {
      if (p.id == id) return p.copyWith(enabled: enabled);
      return p;
    }).toList();
    state = state.copyWith(mainPrayers: updated);
    _saveToPrefs();
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
    _saveToPrefs();
  }

  void setMainPrayerOffsetSeconds(String id, int offsetSeconds) {
    final updated = state.mainPrayers.map((p) {
      if (p.id == id) return p.copyWith(offsetSeconds: offsetSeconds);
      return p;
    }).toList();
    state = state.copyWith(mainPrayers: updated);
    _saveToPrefs();
  }

  void setMainPrayerTemplates(String id, {String? titleTemplate, String? bodyTemplate}) {
    final updated = state.mainPrayers.map((p) {
      if (p.id == id) {
        return p.copyWith(
          titleTemplate: titleTemplate ?? p.titleTemplate,
          bodyTemplate: bodyTemplate ?? p.bodyTemplate,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(mainPrayers: updated);
    _saveToPrefs();
  }

  void toggleNaflPrayer(String id, bool enabled) {
    final updated = state.naflPrayers.map((p) {
      if (p.id == id) return p.copyWith(enabled: enabled);
      return p;
    }).toList();
    state = state.copyWith(naflPrayers: updated);
    _saveToPrefs();
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
    _saveToPrefs();
  }

  void setNaflPrayerOffsetSeconds(String id, int offsetSeconds) {
    final updated = state.naflPrayers.map((p) {
      if (p.id == id) return p.copyWith(offsetSeconds: offsetSeconds);
      return p;
    }).toList();
    state = state.copyWith(naflPrayers: updated);
    _saveToPrefs();
  }

  void setNaflPrayerTemplates(String id, {String? titleTemplate, String? bodyTemplate}) {
    final updated = state.naflPrayers.map((p) {
      if (p.id == id) {
        return p.copyWith(
          titleTemplate: titleTemplate ?? p.titleTemplate,
          bodyTemplate: bodyTemplate ?? p.bodyTemplate,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(naflPrayers: updated);
    _saveToPrefs();
  }

  void toggleAppNews(bool enabled) {
    state = state.copyWith(appNewsEnabled: enabled);
    _saveToPrefs();
  }

  void toggleCommunityPosts(bool enabled) {
    state = state.copyWith(communityPostsEnabled: enabled);
    _saveToPrefs();
  }
}

final detailedNotificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, DetailedNotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});
