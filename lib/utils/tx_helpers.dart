import '../models/transaction.dart';
import '../providers/month_provider.dart';
import '../providers/transaction_provider.dart';

List<Transaction> forAccount(Iterable<Transaction> txs, int? accountId) {
  if (accountId == null) return txs.toList();
  return txs
      .where((t) => t.accountId == accountId || t.toAccountId == accountId)
      .toList();
}

List<Transaction> inMonth(Iterable<Transaction> txs, DateTime month) {
  return txs
      .where((t) => t.date.year == month.year && t.date.month == month.month)
      .toList();
}

List<DayGroup> groupByDay(Iterable<Transaction> txs) {
  final map = <DateTime, List<Transaction>>{};
  for (final t in txs) {
    final day = DateTime(t.date.year, t.date.month, t.date.day);
    map.putIfAbsent(day, () => []).add(t);
  }
  final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final d in days) DayGroup(d, map[d]!)];
}

List<Summary> yearlySummaries(Iterable<Transaction> txs, int year) {
  return [
    for (var m = 1; m <= 12; m++)
      summarize(txs.where((t) => t.date.year == year && t.date.month == m)),
  ];
}
