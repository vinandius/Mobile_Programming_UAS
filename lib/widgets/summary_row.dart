import 'package:flutter/material.dart';

import '../providers/transaction_provider.dart';
import '../utils/helpers.dart';

class SummaryRow extends StatelessWidget {
  final Summary summary;
  const SummaryRow({super.key, required this.summary});

  Widget _cell(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 4),
          Text(
            formatRupiah(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _cell('Income', summary.income, incomeColor),
            VerticalDivider(width: 1),
            _cell('Expense', summary.expense, expenseColor),
            VerticalDivider(width: 1),
            _cell('Total', summary.balance, Colors.black),
          ],
        ),
      ),
    );
  }
}
