import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/qazo_providers.dart';

class QazoScreen extends ConsumerWidget {
  const QazoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(qazoControllerProvider);
    final controller = ref.read(qazoControllerProvider.notifier);

    final rows = [
      ('fajr', 'Bomdod', counts.fajr),
      ('dhuhr', 'Peshin', counts.dhuhr),
      ('asr', 'Asr', counts.asr),
      ('maghrib', 'Shom', counts.maghrib),
      ('isha', 'Xufton', counts.isha),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Qazo namozlar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              child: Column(
                children: [
                  Text('Jami qarz: ${counts.total}', style: AppTextStyles.title),
                  const Text(
                    "Har bir namoz turi uchun qazo miqdorini kuzatib boring.",
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final (key, label, value) in rows) ...[
              AppCard(
                child: Row(
                  children: [
                    Expanded(child: Text(label, style: AppTextStyles.body)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.textSecondary),
                      onPressed: () => controller.decrement(key),
                    ),
                    Text('$value', style: AppTextStyles.title),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                      onPressed: () => controller.increment(key),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
