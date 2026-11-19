import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/notification_settings.dart';
import 'notification_data_source.dart';

class RealNotificationDataSource implements NotificationDataSource {
  final FlutterLocalNotificationsPlugin _plugin;
  static const MethodChannel _androidChannel = MethodChannel('uz.ihda.mobile/notifications');

  bool _initialized = false;
  void Function(String route, String payload)? _onTapCallback;

  RealNotificationDataSource(this._plugin);

  Future<void> init() async {
    if (_initialized) return;

    // 1. Timezone setup
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));
      } catch (_) {}
    }

    // 2. Plugin initialization for iOS
    const androidInit = AndroidInitializationSettings('@drawable/ic_stat_prayer');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!);
            final route = data['targetRoute']?.toString() ?? '/';
            final payload = data['payload']?.toString() ?? '';
            _onTapCallback?.call(route, payload);
          } catch (_) {
            _onTapCallback?.call(response.payload!, '');
          }
        }
      },
    );

    // 3. Android MethodChannel listener for notification tap
    if (Platform.isAndroid) {
      _androidChannel.setMethodCallHandler((call) async {
        if (call.method == 'onNotificationTapped') {
          final map = call.arguments as Map?;
          final route = map?['targetRoute']?.toString() ?? '/';
          final payload = map?['payload']?.toString() ?? '';
          _onTapCallback?.call(route, payload);
        }
      });
    }

    _initialized = true;
  }

  @override
  void setOnNotificationTap(void Function(String route, String payload) callback) {
    _onTapCallback = callback;
  }

  @override
  Future<Map<String, String>?> getInitialNotificationPayload() async {
    await init();
    if (Platform.isAndroid) {
      try {
        final map = await _androidChannel.invokeMethod<Map>('getInitialNotificationPayload');
        if (map != null) {
          return {
            'targetRoute': map['targetRoute']?.toString() ?? '/',
            'payload': map['payload']?.toString() ?? '',
          };
        }
      } catch (_) {}
    } else {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails != null &&
          launchDetails.didNotificationLaunchApp &&
          launchDetails.notificationResponse?.payload != null) {
        try {
          final data = jsonDecode(launchDetails.notificationResponse!.payload!);
          return {
            'targetRoute': data['targetRoute']?.toString() ?? '/',
            'payload': data['payload']?.toString() ?? '',
          };
        } catch (_) {}
      }
    }
    return null;
  }

  @override
  Future<bool> requestPermissions() async {
    await init();

    final status = await Permission.notification.request();

    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
        await androidImpl.requestExactAlarmsPermission();
      }
    } else if (Platform.isIOS) {
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
      }
    }

    return status.isGranted || await hasPermissions();
  }

  @override
  Future<bool> hasPermissions() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.areNotificationsEnabled();
        if (granted == true) return true;
      }
    }

    return status.isGranted;
  }

  @override
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationSoundType soundType,
    String? customAudioPath,
    String targetRoute = '/',
    String payload = '',
  }) async {
    await init();

    if (scheduledTime.isBefore(DateTime.now())) return;

    if (Platform.isAndroid) {
      try {
        await _androidChannel.invokeMethod('scheduleAlarm', {
          'id': id,
          'title': title,
          'body': body,
          'scheduledTimeMs': scheduledTime.millisecondsSinceEpoch,
          'soundKey': soundType.key,
          'customAudioPath': customAudioPath,
          'targetRoute': targetRoute,
          'payload': payload,
        });
      } catch (_) {}
    } else {
      final details = _buildDarwinDetails(soundType, customAudioPath);
      final location = tz.local;
      final scheduledTzTime = tz.TZDateTime.from(scheduledTime, location);
      final payloadJson = jsonEncode({'targetRoute': targetRoute, 'payload': payload});

      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTzTime,
          NotificationDetails(iOS: details),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: payloadJson,
        );
      } catch (_) {}
    }
  }

  @override
  Future<void> cancelForPrayer(int id) async {
    await init();
    if (Platform.isAndroid) {
      try {
        await _androidChannel.invokeMethod('cancelAlarm', {'id': id});
      } catch (_) {}
    }
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await init();
    if (Platform.isAndroid) {
      try {
        await _androidChannel.invokeMethod('cancelAllAlarms');
      } catch (_) {}
    }
    await _plugin.cancelAll();
  }

  @override
  Future<void> showImmediateTestNotification({
    required String title,
    required String body,
    required NotificationSoundType soundType,
    String? customAudioPath,
    String targetRoute = '/',
    String payload = '',
  }) async {
    await init();
    if (Platform.isAndroid) {
      try {
        await _androidChannel.invokeMethod('showImmediateNotification', {
          'id': 999,
          'title': title,
          'body': body,
          'soundKey': soundType.key,
          'customAudioPath': customAudioPath,
          'targetRoute': targetRoute,
          'payload': payload,
        });
      } catch (_) {}
    } else {
      final details = _buildDarwinDetails(soundType, customAudioPath);
      final payloadJson = jsonEncode({'targetRoute': targetRoute, 'payload': payload});
      await _plugin.show(
        999,
        title,
        body,
        NotificationDetails(iOS: details),
        payload: payloadJson,
      );
    }
  }

  @override
  Future<void> schedule10SecondTestNotification({
    required String title,
    required String body,
    required NotificationSoundType soundType,
    String? customAudioPath,
    String targetRoute = '/',
    String payload = '',
  }) async {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    await schedulePrayerNotification(
      id: 998,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      soundType: soundType,
      customAudioPath: customAudioPath,
      targetRoute: targetRoute,
      payload: payload,
    );
  }

  DarwinNotificationDetails _buildDarwinDetails(
    NotificationSoundType soundType,
    String? customAudioPath,
  ) {
    String? soundFile;
    bool presentSound = true;

    switch (soundType) {
      case NotificationSoundType.azaan:
        soundFile = 'chalo_chalo.mp3';
        break;
      case NotificationSoundType.shortChime:
        soundFile = 'short_chime.mp3';
        break;
      case NotificationSoundType.customDevice:
        if (customAudioPath != null && customAudioPath.isNotEmpty) {
          soundFile = customAudioPath;
        } else {
          soundFile = null;
        }
        break;
      case NotificationSoundType.silent:
        presentSound = false;
        soundFile = null;
        break;
      case NotificationSoundType.defaultSound:
        soundFile = null;
        break;
    }

    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: presentSound,
      sound: soundFile,
    );
  }
}
