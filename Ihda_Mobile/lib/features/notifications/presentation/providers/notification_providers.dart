import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notification_data_source.dart';
import '../../data/datasources/real_notification_data_source.dart';

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
