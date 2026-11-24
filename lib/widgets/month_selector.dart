import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/month_provider.dart';
import '../utils/helpers.dart';

import 'month_pick.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  Future<void> _pickMonth(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedMonthProvider);

    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => MonthPickDialog(initial: current),
    );

    if (picked == null || !context.mounted) return;
    ref.read(selectedMonthProvider.notifier).setMonth(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final notifier = ref.watch(selectedMonthProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: notifier.previous,
          icon: Icon(Icons.chevron_left),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () => _pickMonth(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${monthsName[month.month - 1]} ${month.year}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        IconButton(onPressed: notifier.next, icon: Icon(Icons.chevron_right)),
      ],
    );
  }
}
