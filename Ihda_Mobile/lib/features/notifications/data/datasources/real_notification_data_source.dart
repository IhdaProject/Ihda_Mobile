import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/notification_settings.dart';
import 'notification_data_source.dart';

class RealNotificationDataSource implements NotificationDataSource {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  RealNotificationDataSource(this._plugin);

  Future<void> init() async {
    if (_initialized) return;

    // 1. Initialize timezones and set local timezone location
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));
      } catch (_) {}
    }

    // 2. Plugin initialization
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);

    // 3. Create Default & Azaan Android Channels explicitly
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      const channelAzaan = AndroidNotificationChannel(
        'prayer_channel_azaan_v7',
        'Namoz Vaqti - Azon Ovozi',
        description: 'Namoz vaqtida azon va eslatmalar',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('chalo_chalo'),
        enableVibration: true,
      );

      const channelDefault = AndroidNotificationChannel(
        'prayer_channel_default_v7',
        'Namoz Vaqti - Standart',
        description: 'Namoz vaqtida standart eslatmalar',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await androidImpl.createNotificationChannel(channelAzaan);
      await androidImpl.createNotificationChannel(channelDefault);
    }

    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await init();

    // 1. Request notification permission via permission_handler
    final status = await Permission.notification.request();

    // 2. Request permissions via flutter_local_notifications plugin
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
      await androidImpl.requestExactAlarmsPermission();
    }

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
    }

    return status.isGranted || await hasPermissions();
  }

  @override
  Future<bool> hasPermissions() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.areNotificationsEnabled();
      if (granted == true) return true;
    }

    return status.isGranted;
  }

  Future<NotificationDetails> _buildNotificationDetails({
    required NotificationSoundType soundType,
    String? customAudioPath,
  }) async {
    String channelId;
    String channelName;
    AndroidNotificationSound? androidSound;
    String? iosSound;

    switch (soundType) {
      case NotificationSoundType.azaan:
        channelId = 'prayer_channel_azaan_v7';
        channelName = 'Namoz Vaqti - Azon Ovozi';
        androidSound = const RawResourceAndroidNotificationSound('chalo_chalo');
        iosSound = 'chalo_chalo.mp3';
        break;

      case NotificationSoundType.customDevice:
        if (customAudioPath != null && customAudioPath.isNotEmpty) {
          final hash = customAudioPath.hashCode.abs();
          channelId = 'prayer_channel_custom_$hash';
          channelName = 'Namoz Vaqti - Shaxsiy Ovoz';
          androidSound = UriAndroidNotificationSound(customAudioPath);
          iosSound = customAudioPath;
        } else {
          channelId = 'prayer_channel_default_v7';
          channelName = 'Namoz Vaqti - Standart';
          androidSound = null;
          iosSound = null;
        }
        break;

      case NotificationSoundType.defaultSound:
        channelId = 'prayer_channel_default_v7';
        channelName = 'Namoz Vaqti - Standart';
        androidSound = null;
        iosSound = null;
        break;
    }

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'Namoz vaqtida eslatish bildirishnomasi',
        importance: Importance.max,
        playSound: true,
        sound: androidSound,
        enableVibration: true,
      );
      await androidImpl.createNotificationChannel(channel);
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Namoz vaqtida eslatish bildirishnomasi',
      importance: Importance.max,
      priority: Priority.high,
      sound: androidSound,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: iosSound,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  @override
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationSoundType soundType,
    String? customAudioPath,
  }) async {
    await init();

    final details = await _buildNotificationDetails(
      soundType: soundType,
      customAudioPath: customAudioPath,
    );

    final location = tz.local;
    final scheduledTzTime = tz.TZDateTime(
      location,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );

    final nowTz = tz.TZDateTime.now(location);

    // Skip if in the past
    if (scheduledTzTime.isBefore(nowTz)) return;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTzTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTzTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  @override
  Future<void> cancelForPrayer(int id) async {
    await init();
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  @override
  Future<void> showImmediateTestNotification({
    required String title,
    required String body,
    required NotificationSoundType soundType,
    String? customAudioPath,
  }) async {
    await init();
    final details = await _buildNotificationDetails(
      soundType: soundType,
      customAudioPath: customAudioPath,
    );

    await _plugin.show(
      999,
      title,
      body,
      details,
    );
  }
}
