import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/month_provider.dart';
import '../utils/category_stats.dart';
import '../utils/helpers.dart';
import '../widgets/month_selector.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  String _type = 'expense';

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(monthlyTransactionsProvider).value ?? [];
    final stats = categoryStats(txs, _type);
    final total = stats.fold<int>(0, (a, s) => a + s.total);
    final isIncome = _type == 'income';

    return Scaffold(
      appBar: AppBar(title: const MonthSelector(), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'income', label: Text('Income')),
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
            ),
          ),
          Expanded(
            child: stats.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada ${isIncome ? 'income' : 'expense'} bulan ini',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      SizedBox(
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 70,
                                sections: [
                                  for (final s in stats)
                                    PieChartSectionData(
                                      value: s.total.toDouble(),
                                      color: colorForCategory(s.category),
                                      radius: 40,
                                      showTitle: s.percent >= 6,
                                      title: '${s.percent.round()}%',
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isIncome ? 'Income' : 'Expense',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  FittedBox(
                                    child: Text(
                                      formatRupiah(total),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            for (final s in stats)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: colorForCategory(s.category),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        s.percent < 1
                                            ? '<1%'
                                            : '${s.percent.round()}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(s.category)),
                                    Text(
                                      formatRupiah(s.total),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
