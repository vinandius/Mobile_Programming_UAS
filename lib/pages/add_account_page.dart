import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accounts.dart';
import '../providers/account_provider.dart';
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
              : 'This account has $count transaction(s). '
                    'They will be deleted too and cannot be restored.',
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
              const Text(
                'Group',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final g in _groups)
                    ChoiceChip(
                      label: Text(g),
                      selected: _group == g,
                      onSelected: (_) => setState(() => _group = g),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountCtrl,
                // tanda minus diizinkan, untuk akun yang saldonya bisa negatif
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0',
                  prefixText: 'Rp ',
                ),
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
