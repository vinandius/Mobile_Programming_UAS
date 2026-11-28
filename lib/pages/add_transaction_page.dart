import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accounts.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/account_picker.dart';
import '../widgets/category_grid.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final Transaction? existing;

  const AddTransactionPage({super.key, this.existing});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _titleCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _type = 'expense';
  String _category = 'Food';
  DateTime _date = DateTime.now();
  int? _accountId;
  int? _toAccountId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _titleCtrl.text = e.title;
      _nominalCtrl.text = e.nominal.toString();
      _noteCtrl.text = e.note ?? '';
      _category = e.category;
      _date = e.date;
      _accountId = e.accountId;
      _toAccountId = e.toAccountId;
    }
  }

  String get _title => switch (_type) {
    'income' => 'Income',
    'transfer' => 'Transfer',
    _ => 'Expense',
  };

  List<CategoryItem> get _currentCategories =>
      _type == 'income' ? incomeCategories : expenseCategories;

  int? _defaultTo(List<Accounts> accounts, int? fromId) {
    for (final a in accounts) {
      if (a.id != fromId) return a.id;
    }
    return null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nominalCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final accounts = ref.read(accountProvider).value ?? [];
    final isTransfer = _type == 'transfer';

    final fromId =
        _accountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    final toId = isTransfer
        ? (_toAccountId ?? _defaultTo(accounts, fromId))
        : null;

    final title = _titleCtrl.text.trim();
    final nominal = int.tryParse(_nominalCtrl.text.trim());

    if (fromId == null) {
      setState(() => _error = 'No Account found!');
      return;
    }
    if (!isTransfer && title.isEmpty) {
      setState(() => _error = 'Title can not be empty!');
      return;
    }
    if (nominal == null || nominal <= 0) {
      setState(() => _error = 'Nominal have to be more than 0!');
      return;
    }
    if (isTransfer && (toId == null || toId == fromId)) {
      setState(() => _error = 'Account can not be same!');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final user = ref.read(currentUserProvider)!;
    final note = _noteCtrl.text.trim();

    final t = Transaction(
      id: widget.existing?.id,
      userId: user.id!,
      title: title.isEmpty ? 'Transfer' : title,
      nominal: nominal,
      type: _type,
      category: isTransfer ? 'Transfer' : _category,
      date: _date,
      note: note.isEmpty ? null : note,
      accountId: fromId,
      toAccountId: toId,
    );

    final notifier = ref.read(transactionProvider.notifier);
    if (widget.existing == null) {
      await notifier.add(t);
    } else {
      await notifier.edit(t);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountProvider).value ?? [];
    final isTransfer = _type == 'transfer';

    final fromId =
        _accountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    final toId = _toAccountId ?? _defaultTo(accounts, fromId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? _title : 'Edit $_title'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'income', label: Text('Income')),
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                  ButtonSegment(value: 'transfer', label: Text('Transfer')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() {
                  _type = s.first;
                  if (_type != 'transfer') {
                    _category = _currentCategories.first.name;
                  }
                }),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('${_date.day}/${_date.month}/${_date.year}'),
                  onPressed: _pickDate,
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: isTransfer ? 'Title (optional)' : 'Title',
                  border: const UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _nominalCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              if (isTransfer) ...[
                AccountPicker(
                  label: 'From',
                  accounts: accounts,
                  selectedId: fromId,
                  onSelected: (id) => setState(() => _accountId = id),
                ),
                const SizedBox(height: 15),
                AccountPicker(
                  label: 'To',
                  accounts: accounts,
                  selectedId: toId,
                  onSelected: (id) => setState(() => _toAccountId = id),
                ),
              ] else ...[
                AccountPicker(
                  label: 'Account',
                  accounts: accounts,
                  selectedId: fromId,
                  onSelected: (id) => setState(() => _accountId = id),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                CategoryGrid(
                  items: _currentCategories,
                  selected: _category,
                  onSelected: (name) => setState(() => _category = name),
                ),
              ],
              const SizedBox(height: 15),
              TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: UnderlineInputBorder(),
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
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.existing == null ? 'Save' : 'Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
