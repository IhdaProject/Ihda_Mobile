import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/blurred_bottom_sheet.dart';
import '../providers/finance_provider.dart';
import 'finance_input_decoration.dart';

class FinanceEmergencyFundTab extends ConsumerWidget {
  const FinanceEmergencyFundTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);
    final currencyFormat = NumberFormat('#,###', 'uz_UZ');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final monthlyEssential = state.totalEssentialExpense > 0 ? state.totalEssentialExpense : 4000000.0;
    final goalAmount = monthlyEssential * state.emergencyFundMonths;
    final progress = (state.emergencyFundSaved / goalAmount).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Months selector
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.emergencyFundMonths == 3 ? primaryColor : (isDark ? const Color(0xFF16302A) : Colors.white),
                  foregroundColor: state.emergencyFundMonths == 3 ? Colors.white : (isDark ? Colors.white : Colors.black),
                ),
                onPressed: () => ref.read(financeProvider.notifier).updateEmergencyFundMonths(3),
                child: const Text('3 Oylik Zaxira'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.emergencyFundMonths == 6 ? primaryColor : (isDark ? const Color(0xFF16302A) : Colors.white),
                  foregroundColor: state.emergencyFundMonths == 6 ? Colors.white : (isDark ? Colors.white : Colors.black),
                ),
                onPressed: () => ref.read(financeProvider.notifier).updateEmergencyFundMonths(6),
                child: const Text('6 Oylik Zaxira'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Main Buffer Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16302A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Moliyaviy Xavfsizlik Yostiqchasi Maqsadi', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                '${currencyFormat.format(goalAmount)} UZS',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jamg\'arildi: ${currencyFormat.format(state.emergencyFundSaved)} UZS', style: const TextStyle(fontSize: 12)),
                  Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      label: const Text('Yechib olish'),
                      onPressed: () => _showEditEmergencyDialog(context, ref, state.emergencyFundSaved, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Qo\'shish'),
                      onPressed: () => _showEditEmergencyDialog(context, ref, state.emergencyFundSaved, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        const Text('Bosqichlar (Milestones)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        _MilestoneTile(title: '1-Oy Zaxirasi', amount: monthlyEssential, isDone: state.emergencyFundSaved >= monthlyEssential),
        _MilestoneTile(title: '3-Oy Zaxirasi', amount: monthlyEssential * 3, isDone: state.emergencyFundSaved >= monthlyEssential * 3),
        _MilestoneTile(title: '6-Oy Zaxirasi', amount: monthlyEssential * 6, isDone: state.emergencyFundSaved >= monthlyEssential * 6),
      ],
    );
  }

  void _showEditEmergencyDialog(BuildContext context, WidgetRef ref, double currentSaved, bool isAdd) {
    final controller = TextEditingController();
    showBlurredBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAdd ? 'Zaxiraga Mablag\' Qo\'shish' : 'Zaxiradan Yechib Olish', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: buildModernInputDecoration(
                context: context,
                labelText: 'Summasi (UZS)',
                hintText: '1 000 000',
                prefixIcon: Icons.savings_rounded,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final val = double.tryParse(controller.text) ?? 0.0;
                  if (val > 0) {
                    final newSaved = isAdd ? currentSaved + val : (currentSaved - val).clamp(0.0, double.infinity);
                    ref.read(financeProvider.notifier).updateEmergencyFundSaved(newSaved);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Tasdiqlash', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final String title;
  final double amount;
  final bool isDone;

  const _MilestoneTile({required this.title, required this.amount, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'uz_UZ');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16302A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDone ? Border.all(color: Colors.green.withOpacity(0.4)) : null,
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${currencyFormat.format(amount)} UZS', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
              ],
            ),
          ),
          if (isDone)
            const Text('Bajarildi 🎉', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}
