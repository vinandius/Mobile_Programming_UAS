import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/helpers.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_page.dart';

class AccountDetailPage extends ConsumerWidget {
  final int accountId;

  const AccountDetailPage({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(accountNamesProvider)[accountId] ?? 'Akun';
    final balance = ref.watch(accountBalancesProvider)[accountId] ?? 0;
    final all = ref.watch(transactionProvider).value ?? [];

    final txs = all
        .where((t) => t.accountId == accountId || t.toAccountId == accountId)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Balance', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(balance),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: balance < 0 ? expenseColor : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: txs.isEmpty
                ? const Center(child: Text('No Transactions'))
                : ListView.separated(
                    itemCount: txs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => TransactionTile(
                      transaction: txs[i],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddTransactionPage(existing: txs[i]),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
