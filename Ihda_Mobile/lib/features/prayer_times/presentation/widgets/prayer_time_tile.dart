import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/prayer.dart';

class PrayerTimeTile extends StatelessWidget {
  final Prayer prayer;
  final bool isCurrent;
  final bool isNext;
  final bool muted;

  const PrayerTimeTile({
    super.key,
    required this.prayer,
    this.isCurrent = false,
    this.isNext = false,
    this.muted = false,
  });

  IconData get _icon {
    switch (prayer.type) {
      case PrayerType.fajr:
        return Icons.nightlight_round;
      case PrayerType.sunrise:
        return Icons.wb_twilight_rounded;
      case PrayerType.dhuhr:
        return Icons.wb_sunny_rounded;
      case PrayerType.asr:
        return Icons.wb_sunny_outlined;
      case PrayerType.maghrib:
        return Icons.wb_twilight_rounded;
      case PrayerType.isha:
        return Icons.dark_mode_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlighted = isCurrent || isNext;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: highlighted
                  ? primaryColor.withOpacity(0.18)
                  : (isDark ? Colors.white.withOpacity(0.08) : AppColors.surfaceMuted),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon,
              size: 18,
              color: highlighted
                  ? primaryColor
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),

          // Prayer Label Name
          Expanded(
            child: Text(
              prayer.type.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                color: highlighted
                    ? primaryColor
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
          ),

          // Next Badge
          if (isNext)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Keyingi',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
              ),
            ),

          // Prayer Exact Time (Dark mode adaptive!)
          Text(
            AppDateUtils.formatTime(prayer.time),
            style: TextStyle(
              fontSize: 15,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
              color: highlighted
                  ? primaryColor
                  : (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 10),

          // Notification Bell Icon (Dark mode adaptive!)
          Icon(
            muted ? Icons.notifications_off_outlined : Icons.notifications_active_rounded,
            size: 18,
            color: muted
                ? (isDark ? Colors.white38 : Colors.grey)
                : (highlighted
                    ? primaryColor
                    : (isDark ? Colors.white70 : AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
