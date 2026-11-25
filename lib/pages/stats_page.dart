import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../utils/category_stats.dart';
import '../utils/helpers.dart';
import '../widgets/period_selector.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  String _type = 'expense';

  static const _modeLabels = {
    StatsMode.weekly: 'Weekly',
    StatsMode.monthly: 'Monthly',
    StatsMode.annually: 'Annually',
    StatsMode.period: 'Period',
  };

  Future<void> _pickRange() async {
    final current = ref.read(statsPeriodProvider).range;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: current,
    );

    if (picked != null) {
      ref.read(statsPeriodProvider.notifier).setCustomRange(picked);
    }
  }

  Future<void> _selectMode(StatsMode mode) async {
    if (mode == StatsMode.period) {
      await _pickRange();
      return;
    }
    ref.read(statsPeriodProvider.notifier).setMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(statsTransactionsProvider);
    final stats = categoryStats(txs, _type);
    final total = stats.fold<int>(0, (a, s) => a + s.total);
    final isIncome = _type == 'income';
    final period = ref.watch(statsPeriodProvider);

    return Scaffold(
      appBar: AppBar(title: PeriodSelector(onPickRange: _pickRange)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final m in StatsMode.values)
                    ChoiceChip(
                      label: Text(_modeLabels[m]!),
                      selected: period.mode == m,
                      onSelected: (_) => _selectMode(m),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: [
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
                ? Center(child: Text('No data found'))
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
                                      titleStyle: TextStyle(
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
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  FittedBox(
                                    child: Text(
                                      formatRupiah(total),
                                      style: TextStyle(
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
                        padding: EdgeInsets.all(12),
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(child: Text(s.category)),
                                    Text(
                                      formatRupiah(s.total),
                                      style: TextStyle(
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
