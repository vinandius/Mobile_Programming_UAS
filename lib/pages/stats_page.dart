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

    return Scaffold(appBar: AppBar(title: const MonthSelector()));
  }
}
