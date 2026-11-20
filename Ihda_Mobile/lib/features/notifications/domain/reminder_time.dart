bool isReminderDue(DateTime now, DateTime target) =>
    !now.isBefore(target) &&
    now.difference(target) < const Duration(minutes: 1);
