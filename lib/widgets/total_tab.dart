import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/account_provider.dart';
import '../../providers/month_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/helpers.dart';

class TotalTab extends ConsumerWidget {
  const TotalTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(monthlyTransactionsProvider).value ?? [];
    final accounts = ref.watch(accountProvider).value ?? [];
    final balances = ref.watch(accountBalancesProvider);
    final totalBalance = balances.values.fold<int>(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total saldo semua akun',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                formatRupiah(totalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Per akun (bulan ini)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (final a in accounts)
          Builder(
            builder: (context) {
              final s = summarize(txs.where((t) => t.accountId == a.id));

              return Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            a.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text('Saldo ${formatRupiah(balances[a.id] ?? 0)}'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Income ${formatRupiah(s.income)}',
                            style: const TextStyle(color: incomeColor),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Expense ${formatRupiah(s.expense)}',
                            style: const TextStyle(color: expenseColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}
