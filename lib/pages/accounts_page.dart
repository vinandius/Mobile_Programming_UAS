import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accounts.dart';
import '../providers/account_provider.dart';
import '../utils/helpers.dart';
import 'account_detail_page.dart';
import 'add_account_page.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  static const _groups = ['Cash', 'Account', 'Card'];

  IconData _iconFor(String group) {
    switch (group) {
      case 'Cash':
        return Icons.payments_outlined;
      case 'Card':
        return Icons.credit_card;
      default:
        return Icons.account_balance_outlined;
    }
  }

  void _openForm(BuildContext context, {Accounts? existing}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddAccountPage(existing: existing)),
    );
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

  Widget _groupHeader(String group, int total) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(group, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(
            formatRupiah(total),
            style: TextStyle(
              fontSize: 12,
              color: total < 0 ? expenseColor : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Accounts a, int balance) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListTile(
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundColor: primary.withValues(alpha: 0.12),
        child: Icon(_iconFor(a.group), color: primary),
      ),
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
            onPressed: () => _openForm(context, existing: a),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add account',
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load accounts: $e'),
          ),
        ),
        data: (accounts) {
          // urutan group tetap; group tak dikenal (kalau ada) ditaruh di belakang
          final groupNames = <String>{
            ..._groups,
            ...accounts.map((a) => a.group),
          };

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _cell('Assets', assets, incomeColor),
                      const VerticalDivider(width: 1),
                      _cell('Liabilities', liabilities, expenseColor),
                      const VerticalDivider(width: 1),
                      _cell('Total', assets + liabilities, Colors.black87),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: accounts.isEmpty
                    ? const Center(child: Text('No accounts yet'))
                    : ListView(
                        children: [
                          for (final g in groupNames)
                            ..._section(context, g, accounts, balances),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    String group,
    List<Accounts> accounts,
    Map<int, int> balances,
  ) {
    final items = accounts.where((a) => a.group == group).toList();
    if (items.isEmpty) return [];

    final total = items.fold<int>(0, (s, a) => s + (balances[a.id] ?? 0));

    return [
      _groupHeader(group, total),
      for (final a in items) ...[
        _tile(context, a, balances[a.id] ?? 0),
        const Divider(height: 1),
      ],
    ];
  }
}
