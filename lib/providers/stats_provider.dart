import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../utils/helpers.dart';
import 'transaction_provider.dart';

enum StatsMode { weekly, monthly, annually, period }

class StatsPeriod {
  final StatsMode mode;
  final DateTime anchor;
  final DateTimeRange? custom;

  const StatsPeriod({required this.mode, required this.anchor, this.custom});

  StatsPeriod copyWith({
    StatsMode? mode,
    DateTime? anchor,
    DateTimeRange? custom,
  }) {
    return StatsPeriod(
      mode: mode ?? this.mode,
      anchor: anchor ?? this.anchor,
      custom: custom ?? this.custom,
    );
  }

  DateTimeRange get range {
    final a = anchor;
    switch (mode) {
      case StatsMode.weekly:
        final start = DateTime(a.year, a.month, a.day - (a.weekday - 1));
        return DateTimeRange(
          start: start,
          end: DateTime(start.year, start.month, start.day + 6),
        );
      case StatsMode.monthly:
        return DateTimeRange(
          start: DateTime(a.year, a.month, 1),
          end: DateTime(a.year, a.month + 1, 0),
        );
      case StatsMode.annually:
        return DateTimeRange(
          start: DateTime(a.year, 1, 1),
          end: DateTime(a.year, 12, 31),
        );
      case StatsMode.period:
        return custom ??
            DateTimeRange(
              start: DateTime(a.year, a.month, 1),
              end: DateTime(a.year, a.month + 1, 0),
            );
    }
  }

  String get label {
    final r = range;
    String d(DateTime x) => '${x.day} ${monthsName[x.month - 1]}';

    switch (mode) {
      case StatsMode.weekly:
        return '${d(r.start)} - ${d(r.end)} ${r.end.year}';
      case StatsMode.monthly:
        return '${monthsName[r.start.month - 1]} ${r.start.year}';
      case StatsMode.annually:
        return '${r.start.year}';
      case StatsMode.period:
        return '${d(r.start)} ${r.start.year} - ${d(r.end)} ${r.end.year}';
    }
  }

  StatsPeriod shifted(int step) {
    final a = anchor;
    switch (mode) {
      case StatsMode.weekly:
        return copyWith(anchor: DateTime(a.year, a.month, a.day + 7 * step));
      case StatsMode.monthly:
        return copyWith(anchor: DateTime(a.year, a.month + step, 1));
      case StatsMode.annually:
        return copyWith(anchor: DateTime(a.year + step, a.month, 1));
      case StatsMode.period:
        return this;
    }
  }
}

class StatsPeriodNotifier extends Notifier<StatsPeriod> {
  @override
  StatsPeriod build() {
    return StatsPeriod(mode: StatsMode.monthly, anchor: DateTime.now());
  }

  void setMode(StatsMode mode) => state = state.copyWith(mode: mode);

  void setCustomRange(DateTimeRange range) {
    state = state.copyWith(mode: StatsMode.period, custom: range);
  }

  void previous() => state = state.shifted(-1);
  void next() => state = state.shifted(1);
}

final statsPeriodProvider = NotifierProvider<StatsPeriodNotifier, StatsPeriod>(
  StatsPeriodNotifier.new,
);

final statsTransactionsProvider = Provider<List<Transaction>>((ref) {
  final all = ref.watch(transactionProvider).value ?? [];
  final r = ref.watch(statsPeriodProvider).range;

  final start = DateTime(r.start.year, r.start.month, r.start.day);
  final endExclusive = DateTime(r.end.year, r.end.month, r.end.day + 1);

  return all
      .where((t) => !t.date.isBefore(start) && t.date.isBefore(endExclusive))
      .toList();
});
