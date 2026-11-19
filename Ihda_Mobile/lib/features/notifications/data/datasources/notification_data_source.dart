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
    String targetRoute = '/',
    String payload = '',
  });

  Future<void> cancelForPrayer(int id);
  Future<void> cancelAll();

  Future<void> showImmediateTestNotification({
    required String title,
    required String body,
    required NotificationSoundType soundType,
    String? customAudioPath,
    String targetRoute = '/',
    String payload = '',
  });

  Future<void> schedule10SecondTestNotification({
    required String title,
    required String body,
    required NotificationSoundType soundType,
    String? customAudioPath,
    String targetRoute = '/',
    String payload = '',
  });

  void setOnNotificationTap(void Function(String route, String payload) callback);
  Future<Map<String, String>?> getInitialNotificationPayload();
}
