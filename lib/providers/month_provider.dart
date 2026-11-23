import 'package:flutter/foundation.dart';
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
