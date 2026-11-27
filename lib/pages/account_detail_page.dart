import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/account_provider.dart';
import '../providers/month_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/helpers.dart';
import '../utils/tx_helpers.dart';
import '../widgets/summary_row.dart';
import '../widgets/annually_tab.dart';
import '../widgets/daily_tab.dart';
import '../widgets/monthly_tab.dart';

class AccountDetailPage extends ConsumerWidget {
  final int accountId;

  const AccountDetailPage({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(accountNamesProvider)[accountId] ?? 'Akun';
    final balance = ref.watch(accountBalancesProvider)[accountId] ?? 0;
    final all = ref.watch(transactionProvider).value ?? [];
    final month = ref.watch(selectedMonthProvider);

    final monthSummary = summarize(inMonth(forAccount(all, accountId), month));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          centerTitle: false,
          actions: const [_PeriodAction()],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Monthly'),
              Tab(text: 'Annually'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  const Text(
                    'Saldo',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    formatRupiah(balance),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: balance < 0 ? expenseColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SummaryRow(summary: monthSummary),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DailyTab(accountId: accountId),
                  MonthlyTab(accountId: accountId, showYearHeader: false),
                  AnnuallyTab(accountId: accountId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodAction extends ConsumerWidget {
  const _PeriodAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final notifier = ref.read(selectedMonthProvider.notifier);
    final controller = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final index = controller.index;
        if (index == 2) return const SizedBox.shrink();

        final isYear = index == 1;
        final label = isYear
            ? '${month.year}'
            : '${monthsName[month.month - 1]} ${month.year}';

        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => isYear
                    ? notifier.setMonth(DateTime(month.year - 1, month.month))
                    : notifier.previous(),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => isYear
                    ? notifier.setMonth(DateTime(month.year + 1, month.month))
                    : notifier.next(),
              ),
            ],
          ),
        );
      },
    );
  }
}
