import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/pages/history.dart';
import 'package:money_manager/providers/transaction_provider.dart';

class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(summaryProvider);

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00897B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Balance',
            style: TextStyle(color: Color(0xFF263238), fontSize: 30),
          ),
          Text(
            'Rp${summary.balance}',
            style: TextStyle(
              color: Color(0xFF263238),
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
          Divider(color: Colors.black, thickness: 2, height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Income'),
                      Text(
                        'Rp${summary.income}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(color: Colors.black, thickness: 2, width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Expense'),
                      Text(
                        'Rp${summary.expense}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Details'),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const History(),
                            ),
                          );
                        },
                        icon: Icon(Icons.receipt_long_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
