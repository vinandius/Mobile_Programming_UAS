import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../providers/month_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/day_header.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_row.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_page.dart';

class TransPage extends ConsumerWidget {
  const TransPage({super.key});

  @override
  Widget _item(BuildContext context, WidgetRef ref, Transaction t) {
    return Dismissible(
      key: ValueKey('tx-${t.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete this transaction?"),
            content: Text(t.title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        return ok;
      },
      onDismissed: (_) => ref.read(transactionProvider.notifier).delete(t.id!),
      child: TransactionTile(
        transaction: t,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransactionPage(existing: t)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daygroup = ref.watch(groupedByDayProvider);
    final summary = ref.watch(monthlySummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const MonthSelector()),
      body: Column(
        children: [
          SummaryRow(summary: summary),
          Expanded(
            child: daygroup.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (days) => days.isEmpty
                  ? const Center(child: Text('No transaction'))
                  : ListView(
                      children: [
                        for (final d in days) ...[
                          DayHeader(daygroup: d),
                          for (final t in d.items) _item(context, ref, t),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
