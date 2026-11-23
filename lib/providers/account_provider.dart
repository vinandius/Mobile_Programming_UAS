import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../models/accounts.dart';
import 'auth_provider.dart';
import 'transaction_provider.dart';

class AccountNotifier extends AsyncNotifier<List<Accounts>> {
  @override
  Future<List<Accounts>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    return DbHelper.instance.getAccounts(user.id!);
  }

  Future<void> add(Accounts a) async {
    await DbHelper.instance.addAccount(a);
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit(Accounts a) async {
    await DbHelper.instance.editAccount(a);
    ref.invalidateSelf();
    await future;
  }
}

final accountProvider = AsyncNotifierProvider<AccountNotifier, List<Accounts>>(
  AccountNotifier.new,
);

final accountNamesProvider = Provider<Map<int, String>>((ref) {
  final accounts = ref.watch(accountProvider).value ?? [];
  return {for (final a in accounts) a.id!: a.name};
});

final accountBalancesProvider = Provider<Map<int, int>>((ref) {
  final accounts = ref.watch(accountProvider).value ?? [];
  final transactions = ref.watch(transactionProvider).value ?? [];

  final balances = <int, int>{
    for (final a in accounts) a.id!: a.initialBalance,
  };

  for (final t in transactions) {
    if (t.type == 'income') {
      balances[t.accountId] = (balances[t.accountId] ?? 0) + t.nominal;
    } else if (t.type == 'expense') {
      balances[t.accountId] = (balances[t.accountId] ?? 0) - t.nominal;
    } else if (t.type == 'transfer') {
      balances[t.accountId] = (balances[t.accountId] ?? 0) - t.nominal;
      final to = t.toAccountId;
      if (to != null) {
        balances[to] = (balances[to] ?? 0) + t.nominal;
      }
    }
  }
  return balances;
});
