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

  const NextPrayerCard({super.key, required this.countdown});

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
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
                const SizedBox(height: 12),
                if (countdown.remaining != null)
                  Text(
                    AppDateUtils.formatCountdown(countdown.remaining!),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 44,
                          letterSpacing: 1.5,
                        ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPrayerIcon(next?.type),
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}
