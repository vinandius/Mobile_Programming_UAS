import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accounts.dart';
import '../providers/account_provider.dart';
import '../utils/account_group.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class AddAccountPage extends ConsumerStatefulWidget {
  final Accounts? existing;

  const AddAccountPage({super.key, this.existing});

  @override
  ConsumerState<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends ConsumerState<AddAccountPage> {
  static const _groups = ['Cash', 'Account', 'Card'];

  late final _nameCtrl = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _amountCtrl = TextEditingController(
    text: widget.existing == null
        ? ''
        : widget.existing!.initialBalance.toString(),
  );
  late String _group = widget.existing?.group ?? 'Account';

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickGroup() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Group'),
        children: [
          for (final g in accountGroups)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, g.name),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      g.name,
                      style: TextStyle(
                        fontWeight: g.name == _group
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked != null) setState(() => _group = picked);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final text = _amountCtrl.text.trim();
    final amount = text.isEmpty ? 0 : int.tryParse(text);

    if (name.isEmpty) {
      setState(() => _error = 'Account name is required!');
      return;
    }
    if (amount == null) {
      setState(() => _error = 'Amount must be a number');
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final account = Accounts(
      id: widget.existing?.id,
      userId: user.id!,
      name: name,
      group: _group,
      initialBalance: amount,
    );

    final notifier = ref.read(accountProvider.notifier);
    if (widget.existing == null) {
      await notifier.add(account);
    } else {
      await notifier.edit(account);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final existing = widget.existing!;

    final accounts = ref.read(accountProvider).value ?? [];
    if (accounts.length <= 1) {
      setState(() => _error = 'At least one account is required');
      return;
    }

    final txs = ref.read(transactionProvider).value ?? [];
    final count = txs
        .where(
          (t) => t.accountId == existing.id || t.toAccountId == existing.id,
        )
        .length;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${existing.name}"?'),
        content: Text(
          count == 0
              ? 'This account has no transactions.'
              : 'This account has $count transaction(s).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(accountProvider.notifier).delete(existing.id!);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit account' : 'Add account'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete account',
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text('Group', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickGroup,
                      child: InputDecorator(
                        decoration: InputDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(_group), Icon(Icons.arrow_drop_down)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text('Name', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text('Amount', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                      ],
                      decoration: const InputDecoration(prefixText: 'Rp '),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(isEdit ? 'Save changes' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
