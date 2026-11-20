import 'package:flutter_test/flutter_test.dart';
import 'package:ihda_mobile/features/notifications/domain/reminder_time.dart';

void main() {
  test('delayed tick still delivers once within the target minute', () {
    final target = DateTime(2026, 11, 20, 12, 0, 15);
    expect(isReminderDue(target.add(const Duration(seconds: 2)), target), true);
    expect(isReminderDue(target.subtract(const Duration(seconds: 1)), target),
        false);
    expect(
        isReminderDue(target.add(const Duration(minutes: 1)), target), false);
  });
}
