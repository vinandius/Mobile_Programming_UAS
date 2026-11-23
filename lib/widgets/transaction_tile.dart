import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/account_provider.dart';
import '../utils/helpers.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  IconData _iconFor(String category) {
    for (final c in [...expenseCategories, ...incomeCategories]) {
      if (c.name == category) return c.icon;
    }
    return Icons.category;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(accountNamesProvider);
    final t = transaction;

    final isTransfer = t.type == 'transfer';
    final isIncome = t.type == 'income';

    final color = isTransfer
        ? transferColor
        : (isIncome ? incomeColor : expenseColor);
    final sign = isTransfer ? '' : (isIncome ? "+" : "-");
    final icon = isTransfer ? Icons.swap_horiz : _iconFor(t.category);

    final subtitle = isTransfer
        ? '${names[t.accountId] ?? '?'} -> ${names[t.toAccountId] ?? '?'}'
        : '${t.category} . ${names[t.category] ?? ''}';

    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(t.title),
        subtitle: Text(subtitle),
        trailing: Text(
          '$sign${formatRupiah(t.nominal)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
