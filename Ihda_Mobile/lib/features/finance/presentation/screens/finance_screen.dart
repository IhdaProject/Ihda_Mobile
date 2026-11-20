import '../../../../shared/widgets/responsive_action_row.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/blurred_bottom_sheet.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../domain/models/finance_model.dart';
import '../providers/finance_provider.dart';
import '../widgets/add_transaction_sheet.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  String _filter = 'all'; // 'all', 'expense', 'income'
  bool _showChartInHeader =
      false; // false: Balans + Kirim/Chiqimlar, true: Grafik + Taqsimot Tavsiyalari
  int _selectedChartType =
      0; // 0: Doiraviy (Category Donut), 1: Sana bo'yicha chiziqli (Date Line Chart)

  void _openAddModal(BuildContext context, {required bool isExpense}) {
    showBlurredBottomSheet(
      context: context,
      child: AddTransactionSheet(defaultIsExpense: isExpense),
    );
  }

  void _openEditModal(BuildContext context, TransactionItem item) {
    showBlurredBottomSheet(
      context: context,
      child: AddTransactionSheet(initialItem: item),
    );
  }

  Future<void> _handleSync() async {
    final success = await ref.read(financeProvider.notifier).syncWithServer();
    if (success && mounted) {
      showAppToast(
        context,
        'Ma\'lumotlar serverga muvaffaqiyatli sinxronlashtirildi! ☁️',
        icon: Icons.cloud_done_rounded,
      );
    }
  }

  List<DateBarGroup> _getDateBarGroups(List<TransactionItem> transactions) {
    final map = <String, DateBarGroup>{};
    final dateFormat = DateFormat('dd.MM');

    final sorted = List<TransactionItem>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final t in sorted) {
      final label = dateFormat.format(t.date);
      final existing = map[label];
      final inc = (existing?.income ?? 0.0) + (t.isExpense ? 0.0 : t.amount);
      final exp = (existing?.expense ?? 0.0) + (t.isExpense ? t.amount : 0.0);
      map[label] = DateBarGroup(dateLabel: label, income: inc, expense: exp);
    }

    final list = map.values.toList();
    if (list.length > 6) {
      return list.sublist(list.length - 6);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeProvider);
    final currencyFormat = NumberFormat('#,###', 'uz_UZ');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final filteredTransactions = state.transactions.where((t) {
      if (_filter == 'expense') return t.isExpense;
      if (_filter == 'income') return !t.isExpense;
      return true;
    }).toList();

    // Calculate category totals for Donut Chart
    final categoryTotals = <ExpenseCategory, double>{};
    for (final cat in ExpenseCategory.values) {
      final total = state.transactions
          .where((t) => t.isExpense && t.category == cat)
          .fold(0.0, (sum, t) => sum + t.amount);
      if (total > 0) {
        categoryTotals[cat] = total;
      }
    }

    // Calculate date groups for Date Line Chart
    final dateBarGroups = _getDateBarGroups(state.transactions);

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Shaxsiy Moliya',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (state.hasPendingSync)
                      InkWell(
                        onTap: state.isSyncing ? null : _handleSync,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.amber.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state.isSyncing)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.amber),
                                )
                              else
                                const Icon(Icons.cloud_upload_rounded,
                                    color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'Sync',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),

              // Main ListView
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Main Top Card (Toggles between Balance/Cards & Analytics Chart)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF133E33),
                                  const Color(0xFF0D2821)
                                ]
                              : [Colors.white, const Color(0xFFF0FDF4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.25)),
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
                          // Top Row: Title + Toggle View Mode Button
                          ResponsiveActionRow(
                            children: [
                              Text(
                                _showChartInHeader
                                    ? (_selectedChartType == 0
                                        ? 'Xarajatlar (Doiraviy)'
                                        : 'Sana Bo\'yicha Dinamika (Chiziqli)')
                                    : 'Joriy Sof Balans',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showChartInHeader = !_showChartInHeader;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _showChartInHeader
                                            ? Icons
                                                .account_balance_wallet_rounded
                                            : Icons.show_chart_rounded,
                                        size: 14,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _showChartInHeader
                                            ? 'Balans'
                                            : 'Grafik',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (!_showChartInHeader) ...[
                            // Balance Number Display
                            Text(
                              '${currencyFormat.format(state.currentBalance)} UZS',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: state.currentBalance >= 0
                                    ? (isDark
                                        ? Colors.white
                                        : AppColors.textPrimary)
                                    : Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Daromad and Xarajat Cards
                            Row(
                              children: [
                                // Daromad Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Colors.green.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Flexible(
                                              child: Text(
                                                'Daromad 📈',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () => _openAddModal(
                                                  context,
                                                  isExpense: false),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.add,
                                                        size: 12,
                                                        color: Colors.white),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      'Qo\'shish',
                                                      style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${currencyFormat.format(state.totalIncome)} UZS',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Xarajat Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Colors.red.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Flexible(
                                              child: Text(
                                                'Xarajat 📉',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.redAccent,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () => _openAddModal(
                                                  context,
                                                  isExpense: true),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.add,
                                                        size: 12,
                                                        color: Colors.white),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      'Qo\'shish',
                                                      style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${currencyFormat.format(state.totalExpense)} UZS',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Graphic Analytics Mode (Doiraviy & Sana Bo'yicha Chiziqli Dinamika)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ChoiceChip(
                                  label: const Text('Doiraviy 📊',
                                      style: TextStyle(fontSize: 10)),
                                  selected: _selectedChartType == 0,
                                  onSelected: (_) =>
                                      setState(() => _selectedChartType = 0),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 4),
                                ChoiceChip(
                                  label: const Text('Chiziqli (Dinamika) 📈',
                                      style: TextStyle(fontSize: 10)),
                                  selected: _selectedChartType == 1,
                                  onSelected: (_) =>
                                      setState(() => _selectedChartType = 1),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              height: 165,
                              child: _selectedChartType == 0
                                  ? (categoryTotals.isEmpty
                                      ? const Center(
                                          child: Text(
                                              'Hozircha xarajatlar kiritilmagan',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)))
                                      : CustomPaint(
                                          size:
                                              const Size(double.infinity, 165),
                                          painter: DonutChartPainter(
                                            entries: categoryTotals.entries
                                                .map((e) => ChartEntry(
                                                    e.key.label,
                                                    e.value,
                                                    e.key.color))
                                                .toList(),
                                            total: state.totalExpense,
                                          ),
                                        ))
                                  : (dateBarGroups.isEmpty
                                      ? const Center(
                                          child: Text(
                                              'Hozircha amallar kiritilmagan',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)))
                                      : CustomPaint(
                                          size:
                                              const Size(double.infinity, 165),
                                          painter: DateLineChartPainter(
                                            groups: dateBarGroups,
                                            isDark: isDark,
                                          ),
                                        )),
                            ),
                            const SizedBox(height: 10),

                            if (_selectedChartType == 0 &&
                                categoryTotals.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: categoryTotals.entries.map((e) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                              color: e.key.color,
                                              shape: BoxShape.circle)),
                                      const SizedBox(width: 4),
                                      Text(
                                          '${e.key.label}: ${currencyFormat.format(e.value)}',
                                          style: const TextStyle(fontSize: 10)),
                                    ],
                                  );
                                }).toList(),
                              )
                            else if (_selectedChartType == 1)
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _ChartLegendIndicator(
                                      color: Colors.green,
                                      label: 'Daromad Dinamikasi'),
                                  SizedBox(width: 16),
                                  _ChartLegendIndicator(
                                      color: Colors.redAccent,
                                      label: 'Xarajat Dinamikasi'),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // BODY CONTENT BASED ON VIEW MODE:
                    if (_showChartInHeader) ...[
                      // 1. GRAFIK MODE: Show 50/30/20 Financial Allocation Recommendations
                      const Text(
                        'Tavsiya Etilgan Taqsimot (50/30/20)',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Moliya boshqaruvi bo\'yicha sarflash nisbatlari:',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF16302A) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _AllocationProgressRow(
                              title: 'Zaruriy Xarajatlar (Max 50%)',
                              actual: state.totalEssentialExpense,
                              target: state.target50Essential,
                              color: Colors.blue,
                              isDark: isDark,
                            ),
                            const Divider(height: 14),
                            _AllocationProgressRow(
                              title: 'Ixtiyoriy / Istaklar (Max 30%)',
                              actual: state.totalDiscretionaryExpense,
                              target: state.target30Discretionary,
                              color: Colors.purple,
                              isDark: isDark,
                            ),
                            const Divider(height: 14),
                            _AllocationProgressRow(
                              title: 'Jamg\'arma / Ehson (Min 20%)',
                              actual: max(0.0, state.currentBalance),
                              target: state.target20Savings,
                              color: Colors.green,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // 2. BALANS MODE: Show Kirim va Chiqimlar (Transactions List)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kirim va Chiqimlar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('Barchasi',
                                        style: TextStyle(fontSize: 11)),
                                    selected: _filter == 'all',
                                    onSelected: (_) =>
                                        setState(() => _filter = 'all'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 4),
                                  ChoiceChip(
                                    label: const Text('Xarajat',
                                        style: TextStyle(fontSize: 11)),
                                    selected: _filter == 'expense',
                                    onSelected: (_) =>
                                        setState(() => _filter = 'expense'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 4),
                                  ChoiceChip(
                                    label: const Text('Daromad',
                                        style: TextStyle(fontSize: 11)),
                                    selected: _filter == 'income',
                                    onSelected: (_) =>
                                        setState(() => _filter = 'income'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (filteredTransactions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          child: const Text('Ma\'lumotlar topilmadi',
                              style: TextStyle(color: Colors.grey)),
                        )
                      else
                        ...filteredTransactions.map((t) {
                          return Dismissible(
                            key: Key(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) {
                              ref
                                  .read(financeProvider.notifier)
                                  .removeTransaction(t.id);
                              showAppToast(
                                context,
                                'O\'chirildi: ${t.title}',
                                icon: Icons.delete_outline_rounded,
                              );
                            },
                            child: InkWell(
                              onTap: () => _openEditModal(context, t),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF16302A)
                                      : Colors.white,
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
                                        color:
                                            t.category.color.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(t.category.icon,
                                          color: t.category.color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  t.title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(Icons.edit_outlined,
                                                  size: 14,
                                                  color: Colors.grey
                                                      .withOpacity(0.7)),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${t.category.label} • ${DateFormat('dd.MM.yyyy HH:mm').format(t.date)}',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? Colors.white60
                                                    : Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${t.isExpense ? '-' : '+'}${currencyFormat.format(t.amount)} UZS',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: t.isExpense
                                            ? Colors.redAccent
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],

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
}

class _ChartLegendIndicator extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegendIndicator({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AllocationProgressRow extends StatelessWidget {
  final String title;
  final double actual;
  final double target;
  final Color color;
  final bool isDark;

  const _AllocationProgressRow({
    required this.title,
    required this.actual,
    required this.target,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'uz_UZ');
    final ratio = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${currencyFormat.format(actual)} / ${currencyFormat.format(target)} UZS',
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class ChartEntry {
  final String label;
  final double value;
  final Color color;
  ChartEntry(this.label, this.value, this.color);
}

class DonutChartPainter extends CustomPainter {
  final List<ChartEntry> entries;
  final double total;

  DonutChartPainter({required this.entries, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || entries.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    const strokeWidth = 26.0;
    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -pi / 2;
    for (final entry in entries) {
      if (entry.value <= 0) continue;
      final sweepAngle = (entry.value / total) * 2 * pi;
      final paint = Paint()
        ..color = entry.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle - 0.04, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DateBarGroup {
  final String dateLabel;
  final double income;
  final double expense;

  DateBarGroup({
    required this.dateLabel,
    required this.income,
    required this.expense,
  });
}

class DateLineChartPainter extends CustomPainter {
  final List<DateBarGroup> groups;
  final bool isDark;

  DateLineChartPainter({required this.groups, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (groups.isEmpty) return;

    double maxVal = 0;
    for (final g in groups) {
      if (g.income > maxVal) maxVal = g.income;
      if (g.expense > maxVal) maxVal = g.expense;
    }
    if (maxVal <= 0) return;

    const bottomPadding = 24.0;
    const topPadding = 12.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final count = groups.length;
    final stepX = count > 1 ? size.width / (count - 1) : size.width;

    final incomePoints = <Offset>[];
    final expensePoints = <Offset>[];

    for (int i = 0; i < count; i++) {
      final g = groups[i];
      final x = count > 1 ? i * stepX : size.width / 2;

      final incY =
          topPadding + (chartHeight - (g.income / maxVal) * chartHeight);
      final expY =
          topPadding + (chartHeight - (g.expense / maxVal) * chartHeight);

      incomePoints.add(Offset(x, incY));
      expensePoints.add(Offset(x, expY));
    }

    // Grid lines (horizontal faint lines)
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..strokeWidth = 1.0;
    canvas.drawLine(
        Offset(0, topPadding), Offset(size.width, topPadding), gridPaint);
    canvas.drawLine(Offset(0, topPadding + chartHeight / 2),
        Offset(size.width, topPadding + chartHeight / 2), gridPaint);
    canvas.drawLine(Offset(0, topPadding + chartHeight),
        Offset(size.width, topPadding + chartHeight), gridPaint);

    // 1. Draw Income Line (Green)
    final incomePath = Path();
    final incomeStrokePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (incomePoints.isNotEmpty) {
      incomePath.moveTo(incomePoints.first.dx, incomePoints.first.dy);
      for (int i = 1; i < incomePoints.length; i++) {
        incomePath.lineTo(incomePoints[i].dx, incomePoints[i].dy);
      }
      canvas.drawPath(incomePath, incomeStrokePaint);

      // Draw Income Dots
      final dotPaint = Paint()..color = Colors.green;
      final dotInnerPaint = Paint()..color = Colors.white;
      for (final p in incomePoints) {
        canvas.drawCircle(p, 5.0, dotPaint);
        canvas.drawCircle(p, 2.5, dotInnerPaint);
      }
    }

    // 2. Draw Expense Line (Red)
    final expensePath = Path();
    final expenseStrokePaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (expensePoints.isNotEmpty) {
      expensePath.moveTo(expensePoints.first.dx, expensePoints.first.dy);
      for (int i = 1; i < expensePoints.length; i++) {
        expensePath.lineTo(expensePoints[i].dx, expensePoints[i].dy);
      }
      canvas.drawPath(expensePath, expenseStrokePaint);

      // Draw Expense Dots
      final dotPaint = Paint()..color = Colors.redAccent;
      final dotInnerPaint = Paint()..color = Colors.white;
      for (final p in expensePoints) {
        canvas.drawCircle(p, 5.0, dotPaint);
        canvas.drawCircle(p, 2.5, dotInnerPaint);
      }
    }

    // 3. Draw Date Labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    for (int i = 0; i < count; i++) {
      final g = groups[i];
      final x = count > 1 ? i * stepX : size.width / 2;

      textPainter.text = TextSpan(
        text: g.dateLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      );
      textPainter.layout();
      final labelX = (x - textPainter.width / 2)
          .clamp(0.0, size.width - textPainter.width);
      textPainter.paint(canvas, Offset(labelX, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
