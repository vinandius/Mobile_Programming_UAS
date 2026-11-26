import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/transaction.dart';

const _palette = [
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFFFDD835),
  Color(0xFF43A047),
  Color(0xFF00897B),
  Color(0xFF1E88E5),
  Color(0xFF5E35B1),
  Color(0xFFD81B60),
  Color(0xFF6D4C41),
  Color(0xFF546E7A),
  Color(0xFF8E24AA),
  Color(0xFF7CB342),
];

Color colorForCategory(String name) {
  final names = <String>[];
  for (final c in [...expenseCategories, ...incomeCategories]) {
    if (!names.contains(c.name)) names.add(c.name);
  }
  final i = names.indexOf(name);
  if (i < 0) return Colors.grey;
  return _palette[i % _palette.length];
}

class CategoryStat {
  final String category;
  final int total;
  final double percent;

  const CategoryStat(this.category, this.total, this.percent);
}

List<CategoryStat> categoryStats(Iterable<Transaction> txs, String type) {
  final totals = <String, int>{};
  for (final t in txs) {
    if (t.type != type) continue;
    totals[t.category] = (totals[t.category] ?? 0) + t.nominal;
  }

  final sum = totals.values.fold<int>(0, (a, b) => a + b);
  if (sum == 0) return [];

  final list = [
    for (final e in totals.entries)
      CategoryStat(e.key, e.value, e.value * 100 / sum),
  ];
  list.sort((a, b) => b.total.compareTo(a.total));
  return list;
}
