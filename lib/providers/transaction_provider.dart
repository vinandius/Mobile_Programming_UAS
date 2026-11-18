import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/transactions.dart';
import 'auth_provider.dart';

class TransactionNotifier extends AsyncNotifier<List<Transactions>> {
  @override
  Future<List<Transactions>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    return DbHelper.instance.getTransactions(user.id!);
  }

  Future<void> add(Transactions t) async {
    await DbHelper.instance.addTransaction(t);
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit(Transactions t) async {
    await DbHelper.instance.editTransactions(t);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(Transactions t) async {
    await DbHelper.instance.deleteTransactions(t);
    ref.invalidateSelf();
    await future;
  }
}

final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<Transactions>>(
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
