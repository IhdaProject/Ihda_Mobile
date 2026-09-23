import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';

class QuizResultScreen extends StatelessWidget {
  final bool isCorrect;
  final int pointsEarned;

  const QuizResultScreen({
    super.key,
    required this.isCorrect,
    required this.pointsEarned,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(24 * fontScale),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                        : Theme.of(context).colorScheme.error.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    color: isCorrect ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                    size: 64 * fontScale,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  isCorrect ? 'Barakalla! To\'g\'ri javob' : 'Afsuski, noto\'g\'ri javob',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isCorrect
                      ? 'Siz muvaffaqiyatli javob berdingiz va hisobingizga ball qo\'shildi.'
                      : 'Keyingi safar albatta topasiz. Bilimingizni oshirib boring.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isCorrect)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.military_tech_rounded, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '+$pointsEarned ball qo\'shildi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Asosiy sahifaga qaytish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
