enum NotificationSoundType {
  defaultSound,
  azaan,
  shortChime,
  silent,
  customDevice,
}

extension NotificationSoundTypeX on NotificationSoundType {
  String get label {
    switch (this) {
      case NotificationSoundType.defaultSound:
        return 'Standart tovush';
      case NotificationSoundType.azaan:
        return 'Azon ovozi';
      case NotificationSoundType.shortChime:
        return 'Qisqa tovush';
      case NotificationSoundType.silent:
        return 'Ovozsiz';
      case NotificationSoundType.customDevice:
        return 'Telefondan tanlash';
    }
  }

  String get key {
    switch (this) {
      case NotificationSoundType.defaultSound:
        return 'default';
      case NotificationSoundType.azaan:
        return 'azan';
      case NotificationSoundType.shortChime:
        return 'short_chime';
      case NotificationSoundType.silent:
        return 'silent';
      case NotificationSoundType.customDevice:
        return 'custom';
    }
  }

  static NotificationSoundType fromKey(String? key) {
    switch (key) {
      case 'azan':
        return NotificationSoundType.azaan;
      case 'short_chime':
        return NotificationSoundType.shortChime;
      case 'silent':
        return NotificationSoundType.silent;
      case 'custom':
        return NotificationSoundType.customDevice;
      case 'default':
      default:
        return NotificationSoundType.defaultSound;
    }
  }
}

class PrayerNotificationConfig {
  final String id;
  final String name;
  final bool enabled;
  final NotificationSoundType sound;
  final String? customAudioName;
  final int offsetSeconds; // exact offset in seconds (e.g., -120, 0, +30)
  final String? titleTemplate; // e.g. "{prayerName} vaqti kirdi"
  final String? bodyTemplate; // e.g. "Hozir {prayerName} vaqti kirdi. Soat {time}"
  final String targetRoute;

  const PrayerNotificationConfig({
    required this.id,
    required this.name,
    required this.enabled,
    this.sound = NotificationSoundType.defaultSound,
    this.customAudioName,
    this.offsetSeconds = 0,
    this.titleTemplate,
    this.bodyTemplate,
    this.targetRoute = '/',
  });

  int get offsetMinutes => offsetSeconds ~/ 60;

  String get soundChipLabel {
    if (sound == NotificationSoundType.customDevice &&
        customAudioName != null &&
        customAudioName!.isNotEmpty) {
      return customAudioName!;
    }
    return sound.label;
  }

  String formatTitle(String prayerName, String timeStr) {
    final t = (titleTemplate != null && titleTemplate!.trim().isNotEmpty)
        ? titleTemplate!
        : (id == 'sunrise' ? 'Quyosh chiqishi (Bomdod chiqishi)' : '{prayerName} kirishi (Namoz vaqti)');
    return t.replaceAll('{prayerName}', prayerName).replaceAll('{time}', timeStr);
  }

  String formatBody(String prayerName, String timeStr) {
    if (bodyTemplate != null && bodyTemplate!.trim().isNotEmpty) {
      return bodyTemplate!.replaceAll('{prayerName}', prayerName).replaceAll('{time}', timeStr);
    }
    if (offsetSeconds == 0) {
      return 'Hozir $prayerName vaqti kirdi. ($timeStr)';
    } else if (offsetSeconds < 0) {
      final secs = offsetSeconds.abs();
      final mins = secs ~/ 60;
      final remSecs = secs % 60;
      final timeLabel = mins > 0 ? '$mins daqiqa' : '$remSecs soniya';
      return '$prayerName vaqtiga $timeLabel qoldi.';
    } else {
      final mins = offsetSeconds ~/ 60;
      final remSecs = offsetSeconds % 60;
      final timeLabel = mins > 0 ? '$mins daqiqa' : '$remSecs soniya';
      return '$prayerName vaqtidan $timeLabel o\'tdi.';
    }
  }

  PrayerNotificationConfig copyWith({
    bool? enabled,
    NotificationSoundType? sound,
    String? customAudioName,
    int? offsetSeconds,
    int? offsetMinutes,
    String? titleTemplate,
    String? bodyTemplate,
    String? targetRoute,
  }) {
    return PrayerNotificationConfig(
      id: id,
      name: name,
      enabled: enabled ?? this.enabled,
      sound: sound ?? this.sound,
      customAudioName: customAudioName ?? this.customAudioName,
      offsetSeconds: offsetSeconds ?? (offsetMinutes != null ? offsetMinutes * 60 : this.offsetSeconds),
      titleTemplate: titleTemplate ?? this.titleTemplate,
      bodyTemplate: bodyTemplate ?? this.bodyTemplate,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }
}

class DetailedNotificationSettings {
  final bool globalEnabled;
  final List<PrayerNotificationConfig> mainPrayers;
  final List<PrayerNotificationConfig> naflPrayers;
  final bool appNewsEnabled;
  final bool communityPostsEnabled;

  const DetailedNotificationSettings({
    this.globalEnabled = true,
    this.mainPrayers = const [
      PrayerNotificationConfig(id: 'fajr', name: 'Bomdod', enabled: true, sound: NotificationSoundType.azaan),
      PrayerNotificationConfig(id: 'sunrise', name: 'Quyosh', enabled: true, sound: NotificationSoundType.defaultSound),
      PrayerNotificationConfig(id: 'dhuhr', name: 'Peshshin', enabled: true, sound: NotificationSoundType.azaan),
      PrayerNotificationConfig(id: 'asr', name: 'Asr', enabled: true, sound: NotificationSoundType.azaan),
      PrayerNotificationConfig(id: 'maghrib', name: 'Shom', enabled: true, sound: NotificationSoundType.azaan),
      PrayerNotificationConfig(id: 'isha', name: 'Xufton', enabled: true, sound: NotificationSoundType.azaan),
    ],
    this.naflPrayers = const [
      PrayerNotificationConfig(id: 'ishraq', name: 'Ishroq', enabled: true, sound: NotificationSoundType.defaultSound),
      PrayerNotificationConfig(id: 'duha', name: 'Zuho', enabled: true, sound: NotificationSoundType.defaultSound),
      PrayerNotificationConfig(id: 'tahajjud', name: 'Tahajjud', enabled: true, sound: NotificationSoundType.defaultSound),
    ],
    this.appNewsEnabled = true,
    this.communityPostsEnabled = true,
  });

  DetailedNotificationSettings copyWith({
    bool? globalEnabled,
    List<PrayerNotificationConfig>? mainPrayers,
    List<PrayerNotificationConfig>? naflPrayers,
    bool? appNewsEnabled,
    bool? communityPostsEnabled,
  }) {
    return DetailedNotificationSettings(
      globalEnabled: globalEnabled ?? this.globalEnabled,
      mainPrayers: mainPrayers ?? this.mainPrayers,
      naflPrayers: naflPrayers ?? this.naflPrayers,
      appNewsEnabled: appNewsEnabled ?? this.appNewsEnabled,
      communityPostsEnabled: communityPostsEnabled ?? this.communityPostsEnabled,
    );
  }
}
