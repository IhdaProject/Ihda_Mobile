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

    test('Initial finance state has default values', () {
      final state = container.read(financeProvider);
      expect(state.monthlyIncome, 10000000.0);
      expect(state.monthlyBudgetLimit, 7000000.0);
      expect(state.transactions.isNotEmpty, true);
    });

    test('Adding transaction updates balance and transaction list', () {
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
    });

    test('Updating income modifies monthly income state', () {
      final notifier = container.read(financeProvider.notifier);
      notifier.updateMonthlyIncome(15000000.0);

      final newState = container.read(financeProvider);
      expect(newState.monthlyIncome, 15000000.0);
    });
  });
}
