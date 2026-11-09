import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../providers/finance_provider.dart';

class FinanceInvestmentTab extends ConsumerWidget {
  const FinanceInvestmentTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);
    final currencyFormat = NumberFormat('#,###', 'uz_UZ');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    const years = 5;
    const annualRate = 0.14; // 14% annual return
    final totalInvested = state.monthlyInvestment * 12 * years;
    final futureValue = totalInvested * pow(1 + (annualRate / 12), years * 12) * 0.85;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
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
              const Text('Har Oylik Sarmoya Miqdori', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                '${currencyFormat.format(state.monthlyInvestment)} UZS / oy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 12),
              Slider(
                value: state.monthlyInvestment,
                min: 200000,
                max: 10000000,
                divisions: 49,
                activeColor: primaryColor,
                onChanged: (v) => ref.read(financeProvider.notifier).updateMonthlyInvestment(v),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Projected Growth Result Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, const Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('5 Yildan Keyingi Taxminiy Kapital (14% yillik)', style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                '${currencyFormat.format(futureValue)} UZS',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Asosiy kiritilgan mablag\': ${currencyFormat.format(totalInvested)} UZS',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
