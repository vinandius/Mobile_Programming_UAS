import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/month_provider.dart';
import '../../utils/helpers.dart';
import '../pages/add_transaction_page.dart';

class NoteTab extends ConsumerWidget {
  const NoteTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(monthlyTransactionsProvider).value ?? [];
    final withNote = txs
        .where((t) => (t.note ?? '').trim().isNotEmpty)
        .toList();

    if (withNote.isEmpty) {
      return const Center(child: Text('No data found'));
    }

    return ListView.separated(
      itemBuilder: (context, i) {
        final t = withNote[i];
        final isTransfer = t.type == 'transfer';
        final isIncome = t.type == 'income';
        final color = isTransfer
            ? transferColor
            : (isIncome ? incomeColor : expenseColor);
        final sign = isTransfer ? '' : (isIncome ? '+' : '-');

        return ListTile(
          tileColor: Colors.white,
          title: Text(t.note!),
          subtitle: Text(
            '${t.date.day} ${monthsName[t.date.month - 1]} . ${t.title}',
          ),
          trailing: Text(
            '$sign${formatRupiah(t.nominal)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTransactionPage(existing: t),
              ),
            );
          },
        );
      },
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemCount: withNote.length,
    );
  }
}
