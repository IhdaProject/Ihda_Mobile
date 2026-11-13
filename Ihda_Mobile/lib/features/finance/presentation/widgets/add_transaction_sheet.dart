import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/finance_model.dart';
import '../providers/finance_provider.dart';
import 'finance_input_decoration.dart';
import 'thousands_formatter.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionItem? initialItem;
  final bool defaultIsExpense;

  const AddTransactionSheet({
    super.key,
    this.initialItem,
    this.defaultIsExpense = true,
  });

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late bool _isExpense;
  late ExpenseCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    if (item != null) {
      final formatter = NumberFormat('#,###', 'ru_RU');
      final formattedAmount = formatter.format(item.amount).replaceAll('\u00A0', ' ');
      _titleController = TextEditingController(text: item.title);
      _amountController = TextEditingController(text: formattedAmount);
      _isExpense = item.isExpense;
      _selectedCategory = item.category;
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _isExpense = widget.defaultIsExpense;
      _selectedCategory = _isExpense ? ExpenseCategory.food : ExpenseCategory.salary;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    final cleanAmountStr = _amountController.text.replaceAll(' ', '');
    final amount = double.tryParse(cleanAmountStr) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, nomini va summani to\'g\'ri kiriting')),
      );
      return;
    }

    final notifier = ref.read(financeProvider.notifier);
    if (widget.initialItem != null) {
      final updated = widget.initialItem!.copyWith(
        title: title,
        amount: amount,
        category: _selectedCategory,
        isExpense: _isExpense,
      );
      notifier.updateTransaction(updated);
    } else {
      notifier.addTransaction(
        title: title,
        amount: amount,
        category: _selectedCategory,
        isExpense: _isExpense,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final availableCategories = _isExpense
        ? ExpenseCategory.values.where((c) => c != ExpenseCategory.salary && c != ExpenseCategory.freelance).toList()
        : [ExpenseCategory.salary, ExpenseCategory.freelance, ExpenseCategory.other];

    if (!availableCategories.contains(_selectedCategory)) {
      _selectedCategory = availableCategories.first;
    }

    final isEditing = widget.initialItem != null;

    final sheetTitle = _isExpense
        ? (isEditing ? 'Xarajatni Tahrirlash 🔴' : 'Xarajat Qo\'shish 🔴')
        : (isEditing ? 'Daromadni Tahrirlash 🟢' : 'Daromad Qo\'shish 🟢');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_isExpense ? Colors.redAccent : Colors.green).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isExpense ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
                    color: _isExpense ? Colors.redAccent : Colors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sheetTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isExpense ? Colors.redAccent : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Title Input
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: buildModernInputDecoration(
                context: context,
                labelText: _isExpense ? 'Xarajat nomi' : 'Daromad manbai',
                hintText: _isExpense ? 'Supermarket, Taksi, Ijara...' : 'Oylik maosh, Frilans...',
                prefixIcon: Icons.edit_note_rounded,
              ),
            ),
            const SizedBox(height: 8),

            // Autocomplete suggestions chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: state.titleSuggestions.take(6).map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(suggestion, style: const TextStyle(fontSize: 11)),
                      backgroundColor: isDark
                          ? primaryColor.withOpacity(0.12)
                          : primaryColor.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        setState(() {
                          _titleController.text = suggestion;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Amount Input with 3-digit spaces
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [ThousandsFormatter()],
              onSubmitted: (_) => _submitForm(),
              decoration: buildModernInputDecoration(
                context: context,
                labelText: 'Summasi (UZS)',
                hintText: '1 500 000',
                prefixIcon: Icons.attach_money_rounded,
              ),
            ),
            const SizedBox(height: 16),

            // Category choice chips
            const Text(
              'Kategoriya:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableCategories.map((cat) {
                final isSelected = _selectedCategory == cat;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color
                          : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? cat.color : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: cat.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? Colors.white : cat.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isExpense ? Colors.redAccent : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: _submitForm,
                icon: Icon(isEditing ? Icons.check_rounded : Icons.save_rounded),
                label: Text(
                  isEditing ? 'O\'zgartirishni Saqlash' : 'Saqlash',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
