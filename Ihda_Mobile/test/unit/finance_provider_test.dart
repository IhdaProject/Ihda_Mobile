import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihda_mobile/features/finance/domain/models/finance_model.dart';
import 'package:ihda_mobile/features/finance/presentation/providers/finance_provider.dart';

void main() {
  group('FinanceNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial finance state calculates totals from transactions', () {
      final state = container.read(financeProvider);
      expect(state.transactions.isNotEmpty, true);
      expect(state.totalIncome > 0, true);
      expect(state.totalExpense > 0, true);
      expect(state.currentBalance, state.totalIncome - state.totalExpense);
    });

    test('Adding transaction updates totals and pending sync flag', () {
      final notifier = container.read(financeProvider.notifier);
      final initialCount = container.read(financeProvider).transactions.length;

      notifier.addTransaction(
        title: 'Test Expense',
        amount: 50000.0,
        category: ExpenseCategory.food,
        isExpense: true,
      );

      final newState = container.read(financeProvider);
      expect(newState.transactions.length, initialCount + 1);
      expect(newState.transactions.first.title, 'Test Expense');
      expect(newState.transactions.first.amount, 50000.0);
      expect(newState.hasPendingSync, true);
    });

    test('Server sync resets pending sync status', () async {
      final notifier = container.read(financeProvider.notifier);
      notifier.addTransaction(
        title: 'New Income',
        amount: 1000000.0,
        category: ExpenseCategory.salary,
        isExpense: false,
      );

      expect(container.read(financeProvider).hasPendingSync, true);

      final success = await notifier.syncWithServer();
      expect(success, true);
      expect(container.read(financeProvider).hasPendingSync, false);
    });
  });
}
