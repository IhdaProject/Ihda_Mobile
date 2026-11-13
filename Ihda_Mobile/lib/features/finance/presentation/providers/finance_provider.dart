import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../tasbih/presentation/providers/tasbih_providers.dart';
import '../../domain/models/finance_model.dart';

class FinanceState {
  final List<TransactionItem> transactions;
  final bool hasPendingSync;
  final bool isSyncing;

  const FinanceState({
    this.transactions = const [],
    this.hasPendingSync = false,
    this.isSyncing = false,
  });

  /// Total Income strictly calculated from recorded income transactions
  double get totalIncome {
    return transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total Expense strictly calculated from recorded expense transactions
  double get totalExpense {
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Net Balance strictly calculated as Total Income - Total Expense
  double get currentBalance => totalIncome - totalExpense;

  /// Essential Expenses (Food, Housing, Transport, etc.)
  double get totalEssentialExpense {
    return transactions
        .where((t) => t.isExpense && t.category.isEssential)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Discretionary / Wants Expenses (Coffee, Taxi, Entertainment, etc.)
  double get totalDiscretionaryExpense {
    return transactions
        .where((t) => t.isExpense && !t.category.isEssential)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// 50/30/20 Financial Allocation Targets
  double get target50Essential => totalIncome * 0.50;
  double get target30Discretionary => totalIncome * 0.30;
  double get target20Savings => totalIncome * 0.20;

  /// Title suggestions derived from past transactions + default popular items
  List<String> get titleSuggestions {
    final pastTitles = transactions.map((t) => t.title.trim()).toSet();
    const defaults = [
      'Supermarket',
      'Taksi (Yandex Go)',
      'Uy ijara to\'lovi',
      'Kommunal to\'lovlar',
      'Oylik maosh',
      'Frilans daromadi',
      'Kofe va tushlik',
      'Kiyim-kechak',
      'Bozor xaridi',
    ];
    for (final d in defaults) {
      pastTitles.add(d);
    }
    return pastTitles.toList();
  }

  FinanceState copyWith({
    List<TransactionItem>? transactions,
    bool? hasPendingSync,
    bool? isSyncing,
  }) {
    return FinanceState(
      transactions: transactions ?? this.transactions,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  final SharedPreferences _prefs;

  FinanceNotifier(this._prefs) : super(const FinanceState()) {
    _loadFromPrefs();
  }

  static const String _keyTransactions = 'finance_transactions_list_v2';
  static const String _keyPendingSync = 'finance_pending_sync_v2';

  void _loadFromPrefs() {
    final txStringList = _prefs.getStringList(_keyTransactions);
    final pending = _prefs.getBool(_keyPendingSync) ?? false;

    List<TransactionItem> txs = [];
    if (txStringList != null && txStringList.isNotEmpty) {
      txs = txStringList
          .map((s) => TransactionItem.fromJson(jsonDecode(s)))
          .toList();
    } else {
      // Default initial realistic dataset
      txs = [
        TransactionItem(
          id: '1',
          title: 'Oylik Maosh (Asosiy)',
          amount: 12000000,
          category: ExpenseCategory.salary,
          date: DateTime.now().subtract(const Duration(days: 5)),
          isExpense: false,
        ),
        TransactionItem(
          id: '2',
          title: 'Supermarket xaridi',
          amount: 450000,
          category: ExpenseCategory.food,
          date: DateTime.now().subtract(const Duration(hours: 3)),
          isExpense: true,
        ),
        TransactionItem(
          id: '3',
          title: 'Uy ijara to\'lovi',
          amount: 3500000,
          category: ExpenseCategory.housing,
          date: DateTime.now().subtract(const Duration(days: 1)),
          isExpense: true,
        ),
        TransactionItem(
          id: '4',
          title: 'Taksi (Yandex Go)',
          amount: 35000,
          category: ExpenseCategory.taxi,
          date: DateTime.now().subtract(const Duration(days: 2)),
          isExpense: true,
        ),
        TransactionItem(
          id: '5',
          title: 'Qo\'shimcha Frilans loyihasi',
          amount: 2500000,
          category: ExpenseCategory.freelance,
          date: DateTime.now().subtract(const Duration(days: 3)),
          isExpense: false,
        ),
      ];
      _saveTransactions(txs, pendingSync: false);
    }

    state = FinanceState(
      transactions: txs,
      hasPendingSync: pending,
    );
  }

  void _saveTransactions(List<TransactionItem> txs, {required bool pendingSync}) {
    final list = txs.map((t) => jsonEncode(t.toJson())).toList();
    _prefs.setStringList(_keyTransactions, list);
    _prefs.setBool(_keyPendingSync, pendingSync);
  }

  void addTransaction({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required bool isExpense,
    DateTime? date,
  }) {
    final newItem = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
      isExpense: isExpense,
    );
    final updated = [newItem, ...state.transactions];
    state = state.copyWith(transactions: updated, hasPendingSync: true);
    _saveTransactions(updated, pendingSync: true);
  }

  void updateTransaction(TransactionItem updatedItem) {
    final updated = state.transactions.map((t) {
      return t.id == updatedItem.id ? updatedItem : t;
    }).toList();
    state = state.copyWith(transactions: updated, hasPendingSync: true);
    _saveTransactions(updated, pendingSync: true);
  }

  void removeTransaction(String id) {
    final updated = state.transactions.where((t) => t.id != id).toList();
    state = state.copyWith(transactions: updated, hasPendingSync: true);
    _saveTransactions(updated, pendingSync: true);
  }

  Future<bool> syncWithServer() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(isSyncing: false, hasPendingSync: false);
    _prefs.setBool(_keyPendingSync, false);
    return true;
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FinanceNotifier(prefs);
});
