import '../../domain/entities/notification_settings.dart';

abstract class NotificationDataSource {
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationSoundType soundType,
    String? customAudioPath,
  });
  Future<void> cancelForPrayer(int id);
  Future<void> cancelAll();
  Future<void> showImmediateTestNotification({
    required String title,
    required String body,
    required NotificationSoundType soundType,
    String? customAudioPath,
  });
}
