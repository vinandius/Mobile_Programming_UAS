import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/month_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/tx_helpers.dart';

class AnnuallyTab extends ConsumerWidget {
  final int? accountId;

  const AnnuallyTab({super.key, this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(transactionProvider).value ?? [];
    final month = ref.watch(selectedMonthProvider);
    final notifier = ref.read(selectedMonthProvider.notifier);
    final primary = Theme.of(context).colorScheme.primary;

    final scoped = forAccount(all, accountId);

    final thisYear = DateTime.now().year;
    var firstYear = thisYear;
    var lastYear = thisYear;
    for (final t in scoped) {
      if (t.date.year < firstYear) firstYear = t.date.year;
      if (t.date.year > lastYear) lastYear = t.date.year;
    }
    final years = [for (var y = lastYear; y >= firstYear; y--) y];

    return ListView.separated(
      itemCount: years.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final y = years[i];
        final s = summarize(scoped.where((t) => t.date.year == y));
        final selected = y == month.year;

        return ListTile(
          tileColor: selected ? primary.withValues(alpha: 0.08) : Colors.white,
          title: Text('$y'),
          subtitle: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: formatRupiah(s.income),
                  style: const TextStyle(color: incomeColor),
                ),
                TextSpan(
                  text: formatRupiah(s.expense),
                  style: const TextStyle(color: expenseColor),
                ),
              ],
            ),
          ),
          trailing: Text(
            formatRupiah(s.balance),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: s.balance < 0 ? expenseColor : Colors.black87,
            ),
          ),
          onTap: () {
            notifier.setMonth(DateTime(y, month.month));
            DefaultTabController.of(context).animateTo(1); // ke Monthly
          },
        );
      },
    );
  }
}
