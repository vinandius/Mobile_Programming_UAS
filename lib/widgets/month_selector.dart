import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/month_provider.dart';
import '../utils/helpers.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

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
        Text(
          '${monthsName[month.month - 1]} ${month.year}',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(onPressed: notifier.next, icon: Icon(Icons.chevron_right)),
      ],
    );
  }
}
