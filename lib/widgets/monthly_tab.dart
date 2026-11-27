import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/month_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/tx_helpers.dart';

class MonthlyTab extends ConsumerWidget {
  final int? accountId;

  final bool showYearHeader;

  const MonthlyTab({super.key, this.accountId, this.showYearHeader = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final all = ref.watch(transactionProvider).value ?? [];
    final notifier = ref.read(selectedMonthProvider.notifier);
    final primary = Theme.of(context).colorScheme.primary;

    final yearly = yearlySummaries(forAccount(all, accountId), month.year);

    return Column(
      children: [
        if (showYearHeader) ...[
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      notifier.setMonth(DateTime(month.year - 1, month.month)),
                ),
                Text(
                  '${month.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () =>
                      notifier.setMonth(DateTime(month.year + 1, month.month)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: ListView.separated(
            itemCount: 12,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = yearly[i];
              final selected = i + 1 == month.month;

              return ListTile(
                tileColor: selected
                    ? primary.withValues(alpha: 0.08)
                    : Colors.white,
                title: Text(monthsName[i]),
                subtitle: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: formatRupiah(s.income),
                        style: const TextStyle(color: incomeColor),
                      ),
                      const TextSpan(text: '   '),
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
                  notifier.setMonth(DateTime(month.year, i + 1));
                  DefaultTabController.of(context).animateTo(0); // ke Daily
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
