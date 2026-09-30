import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../../shared/widgets/blurred_bottom_sheet.dart';
import '../../domain/models/finance_model.dart';
import '../providers/finance_provider.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Shaxsiy Moliya & Sarmoya',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded, size: 28),
                      color: primaryColor,
                      onPressed: () => _showAddTransactionModal(context),
                    ),
                  ],
                ),
              ),

              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: primaryColor,
                unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Bosh sahifa'),
                  Tab(text: 'Analitika'),
                  Tab(text: 'Zaxira (Fonds)'),
                  Tab(text: 'Sarmoya'),
                ],
              ),

              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _DashboardTab(),
                    _AnalyticsTab(),
                    _EmergencyFundTab(),
                    _InvestmentTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showBlurredBottomSheet(
      context: context,
      child: const _AddTransactionSheet(),
    );
  }
}

// ==================== 1. DASHBOARD TAB ====================
class _DashboardTab extends ConsumerStatefulWidget {
  const _DashboardTab();

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
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

        // Filter Chips & Header (Scrollable to prevent overflow)
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

// ==================== 2. ANALYTICS TAB ====================
class _AnalyticsTab extends ConsumerStatefulWidget {
  const _AnalyticsTab();

  @override
  ConsumerState<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<_AnalyticsTab> {
  int _selectedChartType = 0; // 0: Donut, 1: Bar

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeProvider);
    final currencyFormat = NumberFormat('#,###', 'uz_UZ');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final categoryTotals = <ExpenseCategory, double>{};
    for (final cat in ExpenseCategory.values) {
      final total = state.transactions
          .where((t) => t.isExpense && t.category == cat)
          .fold(0.0, (sum, t) => sum + t.amount);
      if (total > 0) {
        categoryTotals[cat] = total;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Chart Type Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Doiraviy Grafik 📊', style: TextStyle(fontSize: 12)),
              selected: _selectedChartType == 0,
              selectedColor: primaryColor.withOpacity(0.2),
              onSelected: (s) => setState(() => _selectedChartType = 0),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('Ustunli Grafik 📈', style: TextStyle(fontSize: 12)),
              selected: _selectedChartType == 1,
              selectedColor: primaryColor.withOpacity(0.2),
              onSelected: (s) => setState(() => _selectedChartType = 1),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Visual Chart Container
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
            children: [
              Text(
                _selectedChartType == 0 ? 'Xarajatlar Kategoriyalar Bo\'yicha' : 'Daromad va Xarajatlar Taqqosi',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: _selectedChartType == 0
                    ? (categoryTotals.isEmpty
                        ? const Center(child: Text('Hozircha xarajatlar yo\'q', style: TextStyle(color: Colors.grey)))
                        : CustomPaint(
                            size: const Size(double.infinity, 200),
                            painter: DonutChartPainter(
                              entries: categoryTotals.entries.map((e) => ChartEntry(e.key.label, e.value, e.key.color)).toList(),
                              total: state.totalExpense,
                            ),
                          ))
                    : CustomPaint(
                        size: const Size(double.infinity, 200),
                        painter: BarChartPainter(
                          bars: [
                            BarData('Daromad', state.totalIncome, Colors.green),
                            BarData('Xarajat', state.totalExpense, Colors.redAccent),
                            BarData('Byudjet', state.monthlyBudgetLimit, primaryColor),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (_selectedChartType == 0 && categoryTotals.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: categoryTotals.entries.map((e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: e.key.color, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('${e.key.label}: ${currencyFormat.format(e.value)}', style: const TextStyle(fontSize: 11)),
                        ],
                      )).toList(),
                )
              else if (_selectedChartType == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendItem(color: Colors.green, label: 'Daromad: ${currencyFormat.format(state.totalIncome)}'),
                    _LegendItem(color: Colors.redAccent, label: 'Xarajat: ${currencyFormat.format(state.totalExpense)}'),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Smart Insights Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.15), primaryColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text('Moliyaviy Maslahat & Tahlil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                state.totalExpense <= state.monthlyBudgetLimit
                    ? 'Ajoyib! Siz oylik byudjet limitidan pastda harakat qilyapsiz. Jamg\'armalarni oshirish uchun qulay vaqt 🟢.'
                    : 'Diqqat! Byudjet limiti oshib ketdi. Xarajatlarni qisqartirish tavsiya etiladi 🔴.',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Summary breakdown card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16302A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Zaruriy Xarajatlar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormat.format(state.totalEssentialExpense)} UZS',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ortiqcha / Ixtiyoriy', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormat.format(state.totalDiscretionaryExpense)} UZS',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        const Text('Kategoriyalar Bo\'yicha Tahlil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        for (final cat in ExpenseCategory.values) ...[
          Builder(builder: (context) {
            final catTotal = state.transactions
                .where((t) => t.isExpense && t.category == cat)
                .fold(0.0, (sum, t) => sum + t.amount);
            final ratio = state.totalExpense > 0 ? (catTotal / state.totalExpense).clamp(0.0, 1.0) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16302A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cat.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${currencyFormat.format(catTotal)} UZS', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: cat.color.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
    const strokeWidth = 32.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

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

class BarData {
  final String label;
  final double value;
  final Color color;
  BarData(this.label, this.value, this.color);
}

class BarChartPainter extends CustomPainter {
  final List<BarData> bars;

  BarChartPainter({required this.bars});

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final maxVal = bars.map((b) => b.value).reduce(max);
    if (maxVal <= 0) return;

    final barWidth = size.width / (bars.length * 2.5);
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter()
      ..textDirection = ui.TextDirection.ltr;

    for (int i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final height = (bar.value / maxVal) * (size.height - 40);
      final left = i * (barWidth * 1.8) + 30;
      final top = size.height - height - 30;

      paint.color = bar.color;
      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, height),
        const Radius.circular(8),
      );
      canvas.drawRRect(rRect, paint);

      textPainter.text = TextSpan(
        text: bar.label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(left + (barWidth - textPainter.width) / 2, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}


// ==================== 3. EMERGENCY FUND TAB ====================
class _EmergencyFundTab extends ConsumerWidget {
  const _EmergencyFundTab();

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

// ==================== 4. INVESTMENT TAB ====================
class _InvestmentTab extends ConsumerWidget {
  const _InvestmentTab();

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

// ==================== ADD TRANSACTION SHEET ====================
class _AddTransactionSheet extends ConsumerStatefulWidget {
  const _AddTransactionSheet();

  @override
  ConsumerState<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;
  ExpenseCategory _selectedCategory = ExpenseCategory.food;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final availableCategories = _isExpense
        ? ExpenseCategory.values.where((c) => c != ExpenseCategory.salary && c != ExpenseCategory.freelance).toList()
        : [ExpenseCategory.salary, ExpenseCategory.freelance, ExpenseCategory.other];

    if (!availableCategories.contains(_selectedCategory)) {
      _selectedCategory = availableCategories.first;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tranzaksiya Qo\'shish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ToggleButtons(
                isSelected: [_isExpense, !_isExpense],
                onPressed: (index) {
                  setState(() {
                    _isExpense = index == 0;
                    _selectedCategory = _isExpense ? ExpenseCategory.food : ExpenseCategory.salary;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
                children: const [
                  Text('Xarajat 🔴', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Daromad 🟢', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: buildModernInputDecoration(
              context: context,
              labelText: 'Nomi (masalan: Supermarket)',
              prefixIcon: Icons.edit_note_rounded,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: buildModernInputDecoration(
              context: context,
              labelText: 'Summasi (UZS)',
              hintText: '450 000',
              prefixIcon: Icons.attach_money_rounded,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Kategoriya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableCategories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return FilterChip(
                avatar: Icon(cat.icon, size: 16, color: isSelected ? primaryColor : cat.color),
                label: Text(cat.label, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: primaryColor.withOpacity(0.18),
                checkmarkColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCategory = cat);
                },
              );
            }).toList(),
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
                final title = _titleController.text.trim();
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                if (title.isNotEmpty && amount > 0) {
                  ref.read(financeProvider.notifier).addTransaction(
                        title: title,
                        amount: amount,
                        category: _selectedCategory,
                        isExpense: _isExpense,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Saqlash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration buildModernInputDecoration({
  required BuildContext context,
  required String labelText,
  String? hintText,
  IconData? prefixIcon,
  String? suffixText,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final primaryColor = Theme.of(context).colorScheme.primary;

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    suffixText: suffixText,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryColor) : null,
    filled: true,
    fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    labelStyle: TextStyle(
      fontSize: 13,
      color: isDark ? Colors.white70 : Colors.black54,
    ),
  );
}
