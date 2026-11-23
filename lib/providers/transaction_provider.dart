import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/transaction.dart';
import 'auth_provider.dart';

typedef Summary = ({int income, int expense, int balance});

Summary summarize(Iterable<Transaction> list) {
  var income = 0;
  var expense = 0;
  for (final l in list) {
    if (l.type == 'income') {
      income = income + l.nominal;
    } else if (l.type == 'expense') {
      expense = expense - l.nominal;
    }
  }
  return (income: income, expense: expense, balance: income - expense);
}

class TransactionNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    return DbHelper.instance.getTransactions(user.id!);
  }

  Future<void> add(Transaction t) async {
    await DbHelper.instance.addTransaction(t);
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit(Transaction t) async {
    await DbHelper.instance.editTransactions(t);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(int id) async {
    await DbHelper.instance.deleteTransactions(id);
    ref.invalidateSelf();
    await future;
  }
}

final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<Transaction>>(
      TransactionNotifier.new,
    );

final summaryProvider = Provider<({int income, int expense, int balance})>((
  ref,
) {
  final list = ref.watch(transactionProvider).value ?? [];
  var income = 0;
  var expense = 0;

  for (final t in list) {
    if (t.type == 'income') {
      income += t.nominal;
    } else {
      expense += t.nominal;
    }
  }
  return (income: income, expense: expense, balance: income - expense);
});
