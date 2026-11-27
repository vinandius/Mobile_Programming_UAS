import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accounts.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/helpers.dart';
import '../pages/add_account_page.dart';
import 'account_detail_page.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  static const List<String> accountCategories = [
    'Cash',
    'Accounts',
    'Card',
    'Debit Card',
    'Savings',
    'Top-Up/Prepaid',
    'Investments',
    'Overdrafts',
    'Loan',
    'Insurance',
    'Other',
  ];

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    Accounts? existing,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final result = await showAccountDialog(
      context,
      userId: user.id!,
      existing: existing,
    );
    if (result == null) return;

    final notifier = ref.read(accountProvider.notifier);
    if (existing == null) {
      await notifier.add(result);
    } else {
      await notifier.edit(result);
    }
  }

  Widget _cell(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            formatRupiah(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _parent(String categoryName, int totalCategoryBalance) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            categoryName.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            formatRupiah(totalCategoryBalance),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: totalCategoryBalance < 0 ? expenseColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, Accounts a, int balance) {
    return ListTile(
      tileColor: Colors.white,
      title: Text(a.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatRupiah(balance),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: balance < 0 ? expenseColor : Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Edit account',
            onPressed: () => _openForm(context, ref, existing: a),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AccountDetailPage(accountId: a.id!),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountProvider);
    final balances = ref.watch(accountBalancesProvider);

    var assets = 0;
    var liabilities = 0;
    for (final b in balances.values) {
      if (b >= 0) {
        assets += b;
      } else {
        liabilities += b;
      }
    }
    final total = assets + liabilities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add account',
            onPressed: () => _openForm(context, ref),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Process failed: $e'),
          ),
        ),
        data: (accounts) {
          final Map<String, List<Accounts>> groupedAccounts = {};
          for (final a in accounts) {
            final category = _getCategory(a);
          }
        },
      ),
    );
  }
}
