import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/month_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/transaction_tile.dart';
import '../pages/add_transaction_page.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  int? _selectedDay;

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  Widget _dayCell(int day, DayGroup? g, {required bool isToday}) {
    final primary = Theme.of(context).colorScheme.primary;
    final selected = day == _selectedDay;

    return InkWell(
      onTap: () => setState(() => _selectedDay = day),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.15) : null,
          border: Border.all(
            color: isToday ? primary : Colors.grey,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (g != null && g.summary.income > 0)
              Text(
                formatCompact(g.summary.income),
                maxLines: 1,
                style: TextStyle(color: incomeColor, fontSize: 10),
              ),
            if (g != null && g.summary.expense > 0)
              Text(
                formatCompact(g.summary.expense),
                maxLines: 1,
                style: TextStyle(color: expenseColor, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DateTime>(selectedMonthProvider, (previous, next) {
      setState(() => _selectedDay = null);
    });

    final month = ref.watch(selectedMonthProvider);
    final group = ref.watch(groupedByDayProvider).value ?? [];
    final byDay = {for (final g in group) g.day.day: g};

    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday % 7;
    final now = DateTime.now();
    final isThisMonth = now.year == month.year && now.month == month.month;
    final selectedGroup = _selectedDay == null ? null : byDay[_selectedDay];

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    for (final w in _weekdays)
                      Expanded(
                        child: Center(
                          child: Text(
                            w,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.85,
                  children: [
                    for (var i = 0; i < leading; i++) SizedBox.shrink(),
                    for (var d = 1; d <= daysInMonth; d++)
                      _dayCell(
                        d,
                        byDay[d],
                        isToday: isThisMonth && d == now.day,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_selectedDay == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Choose date to check'),
            )
          else if (selectedGroup == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No transactions'),
            )
          else
            for (final t in selectedGroup.items)
              TransactionTile(
                transaction: t,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTransactionPage(existing: t),
                    ),
                  );
                },
              ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
