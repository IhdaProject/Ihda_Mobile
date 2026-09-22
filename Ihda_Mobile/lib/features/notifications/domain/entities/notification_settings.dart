enum NotificationSoundType {
  defaultSound,
  azaan,
  customDevice,
}

extension NotificationSoundTypeX on NotificationSoundType {
  String get label {
    switch (this) {
      case NotificationSoundType.defaultSound:
        return 'Standart tovush';
      case NotificationSoundType.azaan:
        return 'Azon ovozi';
      case NotificationSoundType.customDevice:
        return 'Telefondan tanlash';
    }
  }
}

class PrayerNotificationConfig {
  final String id;
  final String name;
  final bool enabled;
  final NotificationSoundType sound;
  final String? customAudioName;
  final int offsetMinutes; // -15 to +15 minutes

  const PrayerNotificationConfig({
    required this.id,
    required this.name,
    required this.enabled,
    this.sound = NotificationSoundType.defaultSound,
    this.customAudioName,
    this.offsetMinutes = 0,
  });

  String get soundChipLabel {
    if (sound == NotificationSoundType.customDevice &&
        customAudioName != null &&
        customAudioName!.isNotEmpty) {
      return customAudioName!;
    }
    return sound.label;
  }

  PrayerNotificationConfig copyWith({
    bool? enabled,
    NotificationSoundType? sound,
    String? customAudioName,
    int? offsetMinutes,
  }) {
    return PrayerNotificationConfig(
      id: id,
      name: name,
      enabled: enabled ?? this.enabled,
      sound: sound ?? this.sound,
      customAudioName: customAudioName ?? this.customAudioName,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
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
