import 'package:flutter/material.dart';

enum ExpenseCategory {
  salary('Oylik Maosh', Icons.work_rounded, Color(0xFF10B981), true),
  freelance('Qo\'shimcha Daromad', Icons.trending_up_rounded, Color(0xFF3B82F6), true),
  food('Oziq-ovqat', Icons.restaurant_rounded, Color(0xFF3B82F6), true),
  housing('Ijara va Kommunal', Icons.home_rounded, Color(0xFF10B981), true),
  transport('Transport', Icons.directions_car_rounded, Color(0xFFF59E0B), true),
  coffee('Kofe va Tamaddi', Icons.coffee_rounded, Color(0xFFEC4899), false),
  taxi('Taksi', Icons.local_taxi_rounded, Color(0xFF8B5CF6), false),
  entertainment('Ko\'ngilochar', Icons.sports_esports_rounded, Color(0xFF6366F1), false),
  other('Boshqa', Icons.category_rounded, Color(0xFF64748B), true);

  final String label;
  final IconData icon;
  final Color color;
  final bool isEssential; // Zaruriy vs Ortiqcha/Istak

  const ExpenseCategory(this.label, this.icon, this.color, this.isEssential);
}

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final bool isExpense;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
  });

  TransactionItem copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    bool? isExpense,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category.name,
        'date': date.toIso8601String(),
        'isExpense': isExpense,
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      isExpense: json['isExpense'] ?? true,
    );
  }
}
