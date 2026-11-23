import 'package:flutter/material.dart';

import '../providers/month_provider.dart';
import '../utils/helpers.dart';

class DayHeader extends StatelessWidget {
  final DayGroup daygroup;
  const DayHeader({super.key, required this.daygroup});

  @override
  Widget build(BuildContext context) {
    final s = daygroup.summary;

    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          Text(
            '${daygroup.day.day}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(dayNames[daygroup.day.weekday - 1]),
          const Spacer(),
          Text(
            formatRupiah(s.income),
            style: TextStyle(color: incomeColor, fontSize: 12),
          ),
          const SizedBox(width: 12),
          Text(
            formatRupiah(s.expense),
            style: TextStyle(color: expenseColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
