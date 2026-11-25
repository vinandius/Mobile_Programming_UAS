import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/month_provider.dart';
import '../../utils/helpers.dart';

class MonthlyTab extends ConsumerWidget {
  const MonthlyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final yearly = ref.watch(yearlySummaryProvider);
    final notifier = ref.watch(selectedMonthProvider.notifier);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () =>
                    notifier.setMonth(DateTime(month.year - 1, month.month)),
                icon: Icon(Icons.chevron_left),
              ),
              Text(
                '${month.year}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () =>
                    notifier.setMonth(DateTime(month.year + 1, month.month)),
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: 12,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = yearly[i];
              final selected = i + 1 == month.year;

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
                      const TextSpan(text: ''),
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
                    color: s.balance < 0 ? expenseColor : Colors.black,
                  ),
                ),
                onTap: () {
                  notifier.setMonth(DateTime(month.year, i + 1));
                  DefaultTabController.of(context).animateTo(0);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
