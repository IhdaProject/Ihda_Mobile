import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../tasbih/presentation/providers/tasbih_providers.dart';
import '../../domain/models/finance_model.dart';

class FinanceState {
  final double monthlyIncome;
  final double monthlyBudgetLimit;
  final double monthlySavingsTarget;
  final double emergencyFundSaved;
  final int emergencyFundMonths;
  final double monthlyInvestment;
  final List<TransactionItem> transactions;

  const FinanceState({
    this.monthlyIncome = 12000000.0,
    this.monthlyBudgetLimit = 8000000.0,
    this.monthlySavingsTarget = 1500000.0,
    this.emergencyFundSaved = 7500000.0,
    this.emergencyFundMonths = 3,
    this.monthlyInvestment = 1000000.0,
    this.transactions = const [],
  });

  double get totalIncome {
    return transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount) + monthlyIncome;
  }

  double get totalExpense {
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalEssentialExpense {
    return transactions
        .where((t) => t.isExpense && t.category.isEssential)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalDiscretionaryExpense {
    return transactions
        .where((t) => t.isExpense && !t.category.isEssential)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get currentBalance => totalIncome - totalExpense;

  FinanceState copyWith({
    double? monthlyIncome,
    double? monthlyBudgetLimit,
    double? monthlySavingsTarget,
    double? emergencyFundSaved,
    int? emergencyFundMonths,
    double? monthlyInvestment,
    List<TransactionItem>? transactions,
  }) {
    return FinanceState(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyBudgetLimit: monthlyBudgetLimit ?? this.monthlyBudgetLimit,
      monthlySavingsTarget: monthlySavingsTarget ?? this.monthlySavingsTarget,
      emergencyFundSaved: emergencyFundSaved ?? this.emergencyFundSaved,
      emergencyFundMonths: emergencyFundMonths ?? this.emergencyFundMonths,
      monthlyInvestment: monthlyInvestment ?? this.monthlyInvestment,
      transactions: transactions ?? this.transactions,
    );
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  final SharedPreferences _prefs;

  FinanceNotifier(this._prefs) : super(const FinanceState()) {
    _loadFromPrefs();
  }

  static const String _keyIncome = 'finance_monthly_income';
  static const String _keyBudgetLimit = 'finance_budget_limit';
  static const String _keySavingsTarget = 'finance_savings_target';
  static const String _keyEmergencySaved = 'finance_emergency_saved';
  static const String _keyEmergencyMonths = 'finance_emergency_months';
  static const String _keyInvestment = 'finance_monthly_investment';
  static const String _keyTransactions = 'finance_transactions_list';

  void _loadFromPrefs() {
    final income = _prefs.getDouble(_keyIncome) ?? 12000000.0;
    final budgetLimit = _prefs.getDouble(_keyBudgetLimit) ?? 8000000.0;
    final savingsTarget = _prefs.getDouble(_keySavingsTarget) ?? 1500000.0;
    final emergencySaved = _prefs.getDouble(_keyEmergencySaved) ?? 7500000.0;
    final emergencyMonths = _prefs.getInt(_keyEmergencyMonths) ?? 3;
    final investment = _prefs.getDouble(_keyInvestment) ?? 1000000.0;

    final txStringList = _prefs.getStringList(_keyTransactions);
    List<TransactionItem> txs = [];
    if (txStringList != null && txStringList.isNotEmpty) {
      txs = txStringList
          .map((s) => TransactionItem.fromJson(jsonDecode(s)))
          .toList();
    } else {
      txs = [
        TransactionItem(
          id: '1',
          title: 'Supermarket xaridi',
          amount: 450000,
          category: ExpenseCategory.food,
          date: DateTime.now().subtract(const Duration(hours: 2)),
          isExpense: true,
        ),
        TransactionItem(
          id: '2',
          title: 'Uy ijara to\'lovi',
          amount: 3500000,
          category: ExpenseCategory.housing,
          date: DateTime.now().subtract(const Duration(days: 1)),
          isExpense: true,
        ),
        TransactionItem(
          id: '3',
          title: 'Yandex Taxi',
          amount: 35000,
          category: ExpenseCategory.taxi,
          date: DateTime.now().subtract(const Duration(days: 2)),
          isExpense: true,
        ),
        TransactionItem(
          id: '4',
          title: 'Qo\'shimcha Frilans',
          amount: 2500000,
          category: ExpenseCategory.freelance,
          date: DateTime.now().subtract(const Duration(days: 3)),
          isExpense: false,
        ),
      ];
      _saveTransactions(txs);
    }

    state = FinanceState(
      monthlyIncome: income,
      monthlyBudgetLimit: budgetLimit,
      monthlySavingsTarget: savingsTarget,
      emergencyFundSaved: emergencySaved,
      emergencyFundMonths: emergencyMonths,
      monthlyInvestment: investment,
      transactions: txs,
    );
  }

  void _saveTransactions(List<TransactionItem> txs) {
    final list = txs.map((t) => jsonEncode(t.toJson())).toList();
    _prefs.setStringList(_keyTransactions, list);
  }

  void addTransaction({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required bool isExpense,
  }) {
    final newItem = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
      isExpense: isExpense,
    );
    final updated = [newItem, ...state.transactions];
    state = state.copyWith(transactions: updated);
    _saveTransactions(updated);
  }

  void removeTransaction(String id) {
    final updated = state.transactions.where((t) => t.id != id).toList();
    state = state.copyWith(transactions: updated);
    _saveTransactions(updated);
  }

  void updateMonthlyIncome(double income) {
    state = state.copyWith(monthlyIncome: income);
    _prefs.setDouble(_keyIncome, income);
  }

  void updateMonthlyBudgetLimit(double limit) {
    state = state.copyWith(monthlyBudgetLimit: limit);
    _prefs.setDouble(_keyBudgetLimit, limit);
  }

  void updateMonthlySavingsTarget(double target) {
    state = state.copyWith(monthlySavingsTarget: target);
    _prefs.setDouble(_keySavingsTarget, target);
  }

  void updateEmergencyFundSaved(double saved) {
    state = state.copyWith(emergencyFundSaved: saved);
    _prefs.setDouble(_keyEmergencySaved, saved);
  }

  void updateEmergencyFundMonths(int months) {
    state = state.copyWith(emergencyFundMonths: months);
    _prefs.setInt(_keyEmergencyMonths, months);
  }

  void updateMonthlyInvestment(double investment) {
    state = state.copyWith(monthlyInvestment: investment);
    _prefs.setDouble(_keyInvestment, investment);
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FinanceNotifier(prefs);
});
