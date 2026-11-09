import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/finance_model.dart';
import '../providers/finance_provider.dart';
import 'finance_input_decoration.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
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
