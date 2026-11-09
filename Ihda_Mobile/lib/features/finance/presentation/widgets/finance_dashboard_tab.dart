import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/blurred_bottom_sheet.dart';
import '../providers/finance_provider.dart';
import 'finance_input_decoration.dart';

class FinanceDashboardTab extends ConsumerStatefulWidget {
  const FinanceDashboardTab({super.key});

  @override
  ConsumerState<FinanceDashboardTab> createState() => _FinanceDashboardTabState();
}

class _FinanceDashboardTabState extends ConsumerState<FinanceDashboardTab> {
  String _filter = 'all'; // 'all', 'expense', 'income'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeProvider);
    final currencyFormat = NumberFormat('#,###', 'uz_UZ');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final spentRatio = state.monthlyBudgetLimit > 0
        ? (state.totalExpense / state.monthlyBudgetLimit).clamp(0.0, 1.0)
        : 0.0;

    final filteredTransactions = state.transactions.where((t) {
      if (_filter == 'expense') return t.isExpense;
      if (_filter == 'income') return !t.isExpense;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Balance & Budget Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF133E33), const Color(0xFF0D2821)]
                  : [Colors.white, const Color(0xFFF0FDF4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Joriy Sof Balans',
                    style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _showEditIncomeDialog(context, ref, state.monthlyIncome),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${currencyFormat.format(state.currentBalance)} UZS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.edit_outlined, size: 18, color: primaryColor.withOpacity(0.7)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showEditIncomeDialog(context, ref, state.monthlyIncome),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daromad 📈', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('${currencyFormat.format(state.totalIncome)} UZS', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showEditBudgetDialog(context, ref, state.monthlyBudgetLimit),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Byudjet Limiti 🎯', style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('${currencyFormat.format(state.monthlyBudgetLimit)} UZS', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Budget Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sarflandi: ${currencyFormat.format(state.totalExpense)} UZS',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(spentRatio * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: spentRatio > 0.9 ? Colors.red : primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: spentRatio,
                      minHeight: 10,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        spentRatio > 0.9 ? Colors.red : (spentRatio > 0.7 ? Colors.amber : primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Filter Chips & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tranzaksiyalar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Barchasi', style: TextStyle(fontSize: 11)),
                      selected: _filter == 'all',
                      onSelected: (s) => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Xarajat', style: TextStyle(fontSize: 11)),
                      selected: _filter == 'expense',
                      onSelected: (s) => setState(() => _filter = 'expense'),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Daromad', style: TextStyle(fontSize: 11)),
                      selected: _filter == 'income',
                      onSelected: (s) => setState(() => _filter = 'income'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Transactions list
        if (filteredTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: const Text('Tranzaksiyalar topilmadi', style: TextStyle(color: Colors.grey)),
          )
        else
          ...filteredTransactions.map((t) => Dismissible(
                key: Key(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(financeProvider.notifier).removeTransaction(t.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('O\'chirildi: ${t.title}')),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16302A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: t.category.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(t.category.icon, color: t.category.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t.category.label} • ${DateFormat('dd.MM.yyyy HH:mm').format(t.date)}',
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${t.isExpense ? '-' : '+'}${currencyFormat.format(t.amount)} UZS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: t.isExpense ? Colors.redAccent : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  void _showEditIncomeDialog(BuildContext context, WidgetRef ref, double current) {
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    showBlurredBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Oylik Daromadni O\'zgartirish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: buildModernInputDecoration(
                context: context,
                labelText: 'Oylik Daromad (UZS)',
                hintText: '12 000 000',
                prefixIcon: Icons.payments_rounded,
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
                  final val = double.tryParse(controller.text);
                  if (val != null && val >= 0) {
                    ref.read(financeProvider.notifier).updateMonthlyIncome(val);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Saqlash', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, double current) {
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    showBlurredBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Byudjet Limitini O\'zgartirish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: buildModernInputDecoration(
                context: context,
                labelText: 'Byudjet Limiti (UZS)',
                hintText: '8 000 000',
                prefixIcon: Icons.account_balance_rounded,
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
                  final val = double.tryParse(controller.text);
                  if (val != null && val >= 0) {
                    ref.read(financeProvider.notifier).updateMonthlyBudgetLimit(val);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Saqlash', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
