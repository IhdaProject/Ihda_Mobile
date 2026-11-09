import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/finance_model.dart';
import '../providers/finance_provider.dart';

class FinanceAnalyticsTab extends ConsumerStatefulWidget {
  const FinanceAnalyticsTab({super.key});

  @override
  ConsumerState<FinanceAnalyticsTab> createState() => _FinanceAnalyticsTabState();
}

class _FinanceAnalyticsTabState extends ConsumerState<FinanceAnalyticsTab> {
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
