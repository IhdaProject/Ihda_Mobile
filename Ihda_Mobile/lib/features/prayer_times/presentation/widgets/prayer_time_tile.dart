import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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
    final highlighted = isCurrent || isNext;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: highlighted
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon,
              size: 18,
              color: highlighted ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prayer.type.label,
              style: AppTextStyles.body.copyWith(
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          if (isNext)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Next', style: TextStyle(fontSize: 11, color: AppColors.accent)),
            ),
          Text(
            AppDateUtils.formatTime(prayer.time),
            style: AppTextStyles.body.copyWith(
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              color: highlighted ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            muted ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
