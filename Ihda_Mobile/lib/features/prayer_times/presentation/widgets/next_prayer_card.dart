import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/prayer.dart';
import '../providers/prayer_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final next = countdown.next;
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location & Calendar Quick Bar inside Card
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
                    color: Colors.white.withOpacity(0.2),
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qolgan vaqt:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        next?.type.label ?? 'Kutish...',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      if (countdown.remaining != null)
                        RepaintBoundary(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppDateUtils.formatCountdown(countdown.remaining!),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 40,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(14 * fontScale),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getPrayerIcon(next?.type),
                    color: Colors.white,
                    size: 38 * fontScale,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
