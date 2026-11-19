import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/prayer.dart';
import '../providers/prayer_providers.dart';
import 'hourglass_timer_widget.dart';

class NextPrayerCard extends StatelessWidget {
  final PrayerCountdown countdown;
  final String cityName;
  final VoidCallback onTap;

  const NextPrayerCard({
    super.key,
    required this.countdown,
    required this.cityName,
    required this.onTap,
  });

  IconData _getPrayerIcon(PrayerType? type) {
    switch (type) {
      case PrayerType.fajr:
        return Icons.nights_stay_rounded;
      case PrayerType.sunrise:
        return Icons.wb_sunny_outlined;
      case PrayerType.dhuhr:
        return Icons.wb_sunny_rounded;
      case PrayerType.asr:
        return Icons.wb_twilight_rounded;
      case PrayerType.maghrib:
        return Icons.wb_twilight_outlined;
      case PrayerType.isha:
        return Icons.dark_mode_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  PrayerUrgencyLevel _calculateUrgency(PrayerCountdown countdown) {
    // If hourglass is hidden or remaining is null -> NO urgency colors!
    if (countdown.hideHourglass) return PrayerUrgencyLevel.normal;

    final remaining = countdown.remaining;
    if (remaining == null) return PrayerUrgencyLevel.normal;

    final minutes = remaining.inMinutes;

    if (minutes <= countdown.redWarningMinutes) {
      return PrayerUrgencyLevel.critical;
    }
    if (minutes <= countdown.yellowWarningMinutes) {
      return PrayerUrgencyLevel.warning;
    }
    return PrayerUrgencyLevel.normal;
  }

  double _calculateProgress(PrayerCountdown countdown) {
    final current = countdown.current;
    final next = countdown.next;
    final remaining = countdown.remaining;

    if (next == null || remaining == null) return 0.0;

    if (current != null) {
      final totalSeconds = next.time.difference(current.time).inSeconds;
      if (totalSeconds <= 0) return 0.0;
      final elapsedSeconds = totalSeconds - remaining.inSeconds;
      return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
    } else {
      const defaultTotalSeconds = 4 * 3600;
      final elapsed = defaultTotalSeconds - remaining.inSeconds;
      return (elapsed / defaultTotalSeconds).clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = countdown.next;
    final remaining = countdown.remaining;
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);

    final urgency = _calculateUrgency(countdown);
    final progress = _calculateProgress(countdown);

    final targetTimeStr = next != null ? AppDateUtils.formatTime(next.time) : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          // Translucent glassmorphic container with dynamic urgency color hints
          gradient: LinearGradient(
            colors: urgency == PrayerUrgencyLevel.critical
                ? [const Color(0xFFE11D48).withValues(alpha: 0.36), const Color(0xFF9F1239).withValues(alpha: 0.24)]
                : (urgency == PrayerUrgencyLevel.warning
                    ? [const Color(0xFFF59E0B).withValues(alpha: 0.34), const Color(0xFFB45309).withValues(alpha: 0.22)]
                    : [Colors.black.withValues(alpha: 0.26), Colors.black.withValues(alpha: 0.14)]),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: urgency == PrayerUrgencyLevel.critical
                ? const Color(0xFFFB7185).withValues(alpha: 0.65)
                : (urgency == PrayerUrgencyLevel.warning
                    ? const Color(0xFFFBBF24).withValues(alpha: 0.60)
                    : Colors.white.withValues(alpha: 0.22)),
            width: urgency == PrayerUrgencyLevel.critical ? 1.5 : 1.0,
          ),
          boxShadow: urgency == PrayerUrgencyLevel.critical
              ? [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Location + Target Time + Calendar Link
            Row(
              children: [
                Icon(Icons.place_rounded, size: 14 * fontScale, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Taqvim',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 12, color: Colors.white70),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Main Content Row: Target Prayer Title + Dynamic Countdown Subtitle + Live Timer + Hourglass Ring
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Title & Time Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              countdown.displayTitle,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (targetTimeStr.isNotEmpty) ...[
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                targetTimeStr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Countdown Subtitle & Live Timer
                      Text(
                        countdown.countdownSubtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      if (remaining != null)
                        RepaintBoundary(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppDateUtils.formatCountdown(remaining),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Visual Hourglass & Time Sand Progress Ring Widget
                if (countdown.hideHourglass)
                  Container(
                    padding: EdgeInsets.all(14 * fontScale),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPrayerIcon(next?.type),
                      color: Colors.white,
                      size: 38 * fontScale,
                    ),
                  )
                else
                  HourglassTimerWidget(
                    progress: progress,
                    urgency: urgency,
                    prayerIcon: _getPrayerIcon(next?.type),
                    size: 68 * fontScale,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
