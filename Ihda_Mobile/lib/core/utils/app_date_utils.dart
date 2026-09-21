import 'package:intl/intl.dart';

/// Lightweight date helpers. Hijri conversion here is an approximation
/// (no extra package) - swap in a proper Hijri library later if you need
/// calendar-accurate results.
class AppDateUtils {
  AppDateUtils._();

  static String formatGregorian(DateTime date) =>
      DateFormat('EEEE, d MMMM yyyy').format(date);

  static String formatShort(DateTime date) => DateFormat('d MMM').format(date);

  static String formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  static String formatCountdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static const _hijriMonths = [
    'Muharram', 'Safar', "Rabi' al-awwal", "Rabi' al-thani",
    'Jumada al-awwal', 'Jumada al-thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
  ];

  /// Rough Gregorian -> Hijri approximation (civil algorithm), good enough
  /// for display purposes with mock data.
  static String approximateHijri(DateTime date) {
    final jd = _julianDayNumber(date);
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor() +
        (l2 / 5670).floor() * ((43 * l2) / 15238).floor();
    final l3 = l2 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final month = ((24 * l3) / 709).floor();
    final day = l3 - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;
    final monthName = _hijriMonths[(month - 1).clamp(0, 11)];
    return '$day $monthName $year AH';
  }

  static int _julianDayNumber(DateTime date) {
    final a = ((14 - date.month) / 12).floor();
    final y = date.year + 4800 - a;
    final m = date.month + 12 * a - 3;
    return date.day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }
}
