import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/transaction.dart';
import '../../providers/month_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/tx_helpers.dart';
import '../../widgets/day_header.dart';
import '../../widgets/transaction_tile.dart';
import '../pages/add_transaction_page.dart';

class DailyTab extends ConsumerWidget {
  final int? accountId;

  const DailyTab({super.key, this.accountId});

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
            title: const Text('Delete?'),
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
        return ok ?? false;
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
    final all = ref.watch(transactionProvider);
    final month = ref.watch(selectedMonthProvider);

    return all.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        final days = groupByDay(inMonth(forAccount(list, accountId), month));

        if (days.isEmpty) {
          return const Center(child: Text('No transaction'));
        }

        return ListView(
          children: [
            for (final g in days) ...[
              DayHeader(daygroup: g),
              for (final t in g.items) _item(context, ref, t),
            ],
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
