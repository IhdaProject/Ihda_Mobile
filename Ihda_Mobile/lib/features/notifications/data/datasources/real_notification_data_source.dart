import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../prayer_times/domain/entities/prayer.dart';
import 'notification_data_source.dart';

class RealNotificationDataSource implements NotificationDataSource {
  final FlutterLocalNotificationsPlugin _plugin;

  RealNotificationDataSource(this._plugin);

  Future<void> init() async {
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
  }

  @override
  Future<void> scheduleForPrayer(PrayerType type, DateTime time) async {
    // Sound file placed in:
    // Android: android/app/src/main/res/raw/chalo_chalo.mp3
    // iOS: ios/Runner/chalo_chalo.mp3
    const soundName = 'chalo_chalo';

    final androidDetails = AndroidNotificationDetails(
      'prayer_reminders_v2', // Changed ID to ensure new channel with sound is created
      'Namoz vaqtlari',
      channelDescription: 'Namoz vaqtlarini eslatish uchun',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound(soundName),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: '$soundName.mp3',
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Schedule for the specific time
    final tzTime = tz.TZDateTime.from(time, tz.local);
    
    // If time is in the past, don't schedule (or schedule for tomorrow if needed, 
    // but typically we schedule for today's times when app starts)
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      type.index,
      'Namoz vaqti bo\'ldi',
      'Hozir ${type.label} namozi vaqti kirdi.',
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelForPrayer(PrayerType type) async {
    await _plugin.cancel(type.index);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
