import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../location/presentation/screens/region_selection_screen.dart';
import '../providers/qazo_providers.dart';

class QazoScreen extends ConsumerWidget {
  const QazoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(qazoControllerProvider);
    final controller = ref.read(qazoControllerProvider.notifier);

    final prayers = [
      ('fajr', 'Bomdod', counts.fajr, Icons.wb_twilight_rounded),
      ('dhuhr', 'Peshshin', counts.dhuhr, Icons.wb_sunny_rounded),
      ('asr', 'Asr', counts.asr, Icons.wb_cloudy_rounded),
      ('maghrib', 'Shom', counts.maghrib, Icons.nights_stay_rounded),
      ('isha', 'Xufton', counts.isha, Icons.bedtime_rounded),
    ];

    final daysApprox = (counts.total / 5).floor();

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Qazo Namozlari Hisobi',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
                      tooltip: 'Tozalash',
                      onPressed: () => _showResetConfirmation(context, ref),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Inspirational Header Card
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.format_quote_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"Qazolarni ado etish qalbga xotirjamlik va nur bag\'ishlaydi. Har bir ado etilgan namoz sizni Allohga yaqinlashtiradi."',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '${counts.total}',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const Text('Jami qazo namoz', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                Container(width: 1, height: 36, color: Colors.grey.withOpacity(0.3)),
                                Column(
                                  children: [
                                    Text(
                                      '~$daysApprox',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const Text('Kunlik miqdor', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Quick Add Days Toolbar & Reset Button (Edge-To-Edge Scroll)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _QuickAddChip(
                            label: '+1 kunlik',
                            onTap: () {
                              controller.addDays(1);
                              showAppToast(context, 'Barcha namozlarga +1 kunlik qazo qo\'shildi', icon: Icons.add_circle_outline);
                            },
                          ),
                          const SizedBox(width: 6),
                          _QuickAddChip(
                            label: '+1 oylik (30 kun)',
                            onTap: () {
                              controller.addDays(30);
                              showAppToast(context, 'Barcha namozlarga +30 kunlik qazo qo\'shildi', icon: Icons.add_circle_outline);
                            },
                          ),
                          const SizedBox(width: 6),
                          _QuickAddChip(
                            label: '+1 yillik (365 kun)',
                            onTap: () {
                              controller.addDays(365);
                              showAppToast(context, 'Barcha namozlarga +365 kunlik qazo qo\'shildi', icon: Icons.add_circle_outline);
                            },
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _showResetConfirmation(context, ref),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.refresh_rounded, size: 14, color: Theme.of(context).colorScheme.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tozalash',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 5 Daily Prayers Qazo Cards
                    for (final (key, label, value, icon) in prayers)
                      Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Text('Qazo miqdori', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              // Decrement (-)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.remove_circle_outline_rounded, size: 24),
                                color: value > 0 ? Theme.of(context).colorScheme.primary : Colors.grey,
                                onPressed: value > 0
                                    ? () {
                                        controller.decrement(key);
                                        showAppToast(context, '$label qazosi -1 ado etildi', icon: Icons.check_circle_outline);
                                      }
                                    : null,
                              ),
                              // Clickable Number to Edit Directly
                              GestureDetector(
                                onTap: () => _showEditCountDialog(context, ref, key, label, value),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              // Increment (+)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  controller.increment(key);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qazolarni tozalash'),
        content: const Text('Barcha qazo namozlar hisobini nolga tushirishga ishonchingiz komilmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              final controller = ref.read(qazoControllerProvider.notifier);
              controller.setCount('fajr', 0);
              controller.setCount('dhuhr', 0);
              controller.setCount('asr', 0);
              controller.setCount('maghrib', 0);
              controller.setCount('isha', 0);
              Navigator.pop(context);
              showAppToast(context, 'Barcha qazolar hisobi nolga tushirildi', icon: Icons.refresh_rounded);
            },
            child: const Text('Tozalash'),
          ),
        ],
      ),
    );
  }

  static void _showEditCountDialog(BuildContext context, WidgetRef ref, String key, String label, int currentCount) {
    final controller = TextEditingController(text: '$currentCount');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label qazosini tahrirlash'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Kattaroq raqam kiriting (masalan: 100, 365...)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCount = int.tryParse(controller.text.trim()) ?? currentCount;
              ref.read(qazoControllerProvider.notifier).setCount(key, newCount);
              Navigator.pop(context);
              showAppToast(context, '$label qazosi $newCount ta qilib belgilandi', icon: Icons.edit_note_rounded);
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
