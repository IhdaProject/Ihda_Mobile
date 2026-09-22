import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../providers/tasbih_providers.dart';

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  void _handleTap(WidgetRef ref) {
    final count = ref.read(tasbihCountProvider) + 1;
    ref.read(tasbihCountProvider.notifier).increment();
    
    final limit = ref.read(tasbihLimitProvider);
    final isVibration = ref.read(vibrationEnabledProvider);
    final isSound = ref.read(soundEnabledProvider);

    // Milestone logic (33, 66, 99)
    final isMilestone = (limit > 0 && count % limit == 0);

    if (isVibration) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator == true) {
          if (isMilestone) {
            Vibration.vibrate(duration: 100, amplitude: 255);
          } else {
            Vibration.vibrate(duration: 40);
          }
        } else {
          HapticFeedback.lightImpact();
        }
      });
    }
    
    if (isSound) {
      if (isMilestone) {
        SystemSound.play(SystemSoundType.alert);
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(tasbihCountProvider);
    final isVibration = ref.watch(vibrationEnabledProvider);
    final isSound = ref.watch(soundEnabledProvider);
    final limit = ref.watch(tasbihLimitProvider);
    final isDarkMode = ref.watch(isTasbihDarkModeProvider);

    return Scaffold(
      body: Stack(
        children: [
          DesignBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Top Navigation Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 24,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        _LimitSelector(
                          currentLimit: limit,
                          onChanged: (val) => ref.read(tasbihLimitProvider.notifier).state = val,
                        ),
                        const Spacer(),
                        _SettingToggle(
                          icon: isVibration ? Icons.vibration_rounded : Icons.smartphone_rounded,
                          isActive: isVibration,
                          onTap: () => ref.read(vibrationEnabledProvider.notifier).state = !isVibration,
                        ),
                        const SizedBox(width: 4),
                        _SettingToggle(
                          icon: isSound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          isActive: isSound,
                          onTap: () => ref.read(soundEnabledProvider.notifier).state = !isSound,
                        ),
                        const SizedBox(width: 4),
                        _SettingToggle(
                          icon: Icons.nightlight_round,
                          isActive: isDarkMode,
                          onTap: () => ref.read(isTasbihDarkModeProvider.notifier).state = true,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  
                  // Counter Number Display
                  _TasbihCounter(count: count, limit: limit),
                  
                  const Spacer(flex: 3),
                  
                  // Clean, Simple, Elegant Center Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleTap(ref),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Bosing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Reset Button
                  TextButton.icon(
                    onPressed: () => ref.read(tasbihCountProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Qayta boshlash', style: TextStyle(fontSize: 14)),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          if (isDarkMode)
            _TasbihDarkModeOverlay(
              count: count,
              onTap: () => _handleTap(ref),
              onExit: () => ref.read(isTasbihDarkModeProvider.notifier).state = false,
            ),
        ],
      ),
    );
  }
}

class _LimitSelector extends StatelessWidget {
  final int currentLimit;
  final ValueChanged<int> onChanged;

  const _LimitSelector({required this.currentLimit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [33, 66, 99, 0].map((limit) {
          final isSelected = currentLimit == limit;
          return GestureDetector(
            onTap: () => onChanged(limit),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                limit == 0 ? '∞' : '$limit',
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TasbihCounter extends StatelessWidget {
  final int count;
  final int limit;

  const _TasbihCounter({required this.count, required this.limit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 100,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: -2,
              ),
        ),
        if (limit > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '${(count / limit).floor() + 1}-davra',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SettingToggle({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _TasbihDarkModeOverlay extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  final VoidCallback onExit;

  const _TasbihDarkModeOverlay({
    required this.count,
    required this.onTap,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: onExit,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 60),
                  child: const Text(
                    'Chiqish uchun bosing',
                    style: TextStyle(color: Colors.white24, fontSize: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white12,
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
