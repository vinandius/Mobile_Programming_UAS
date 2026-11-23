import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'transaction_provider.dart';

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);
  void next() => state = DateTime(state.year, state.month + 1);
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);

final monthlyTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final all = ref.watch(transactionProvider);
  final month = ref.watch(selectedMonthProvider);

  return all.whenData(
    (list) => list
        .where((t) => t.date.year == month.year && t.date.month == month.month)
        .toList(),
  );
});

final monthlySummaryProvider = Provider<Summary>(((ref) {
  return summarize(ref.watch(monthlyTransactionsProvider).value ?? []);
}));

class DayGroup {
  final DateTime day;
  final List<Transaction> items;
  DayGroup(this.day, this.items);

  Summary get summary => summarize(items);
}

final groupedByDayProvider = Provider<AsyncValue<List<DayGroup>>>((ref) {
  return ref.watch(monthlyTransactionsProvider).whenData((list) {
    final map = <DateTime, List<Transaction>>{};
    for (final l in list) {
      final day = DateTime(l.date.year, l.date.month, l.date.day);
      map.putIfAbsent(day, () => []).add(l);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [for (final d in days) DayGroup(d, map[d]!)];
  });
});
