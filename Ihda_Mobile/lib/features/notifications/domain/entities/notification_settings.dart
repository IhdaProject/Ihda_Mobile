import '../../../prayer_times/domain/entities/prayer.dart';

class NotificationSettings {
  final bool enabled;
  final Set<PrayerType> mutedPrayers;

  const NotificationSettings({this.enabled = true, this.mutedPrayers = const {}});

  bool isMuted(PrayerType type) => !enabled || mutedPrayers.contains(type);
}
