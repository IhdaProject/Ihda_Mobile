import '../../../prayer_times/domain/entities/prayer.dart';

/// Isolates prayer-reminder scheduling from the concrete notification
/// plumbing (e.g. flutter_local_notifications + permission requests).
/// The mock implementation just logs, so the app never needs notification
/// permissions to start up or to be demoed.
abstract class NotificationDataSource {
  Future<void> scheduleForPrayer(PrayerType type, DateTime time);
  Future<void> cancelForPrayer(PrayerType type);
  Future<void> cancelAll();
}

class MockNotificationDataSource implements NotificationDataSource {
  @override
  Future<void> scheduleForPrayer(PrayerType type, DateTime time) async {
    // ignore: avoid_print
    print('[mock] would schedule ${type.label} reminder at $time');
  }

  @override
  Future<void> cancelForPrayer(PrayerType type) async {
    // ignore: avoid_print
    print('[mock] would cancel ${type.label} reminder');
  }

  @override
  Future<void> cancelAll() async {
    // ignore: avoid_print
    print('[mock] would cancel all reminders');
  }
}
