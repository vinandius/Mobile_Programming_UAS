import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

class PeriodSelector extends ConsumerWidget {
  final VoidCallback onPickRange;

  const PeriodSelector({super.key, required this.onPickRange});

  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);
    final notifier = ref.read(statsPeriodProvider.notifier);
    final isPeriod = period.mode == StatsMode.period;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isPeriod)
          const SizedBox(width: 48)
        else
          IconButton(
            onPressed: notifier.previous,
            icon: Icon(Icons.chevron_left),
          ),
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: isPeriod ? onPickRange : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(period.label, style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ),
        if (isPeriod)
          const SizedBox(width: 48)
        else
          IconButton(onPressed: notifier.next, icon: Icon(Icons.chevron_right)),
      ],
    );
  }
}
