import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/models/category.dart';

import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

import '../widgets/category_grid.dart';
import '../models/accounts.dart';

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
    'income' => 'income',
    'transfer' => 'transfer',
    _ => 'expense',
  };

  List<CategoryItem> get _currentCategories =>
      _type == 'income' ? incomeCategories : expenseCategories;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nominalCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) setState(() => _date = pickedDate);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final nominal = int.tryParse(_nominalCtrl.text.trim());

    if (_type == 'transfer') {
      setState(() => _error = 'No Accounts made.');
    }

    if (title.isEmpty) {
      setState(() => _error = 'Title can not be empty!');
      return;
    }

    if (nominal == null || nominal <= 0) {
      setState(() => _error = 'Nominal must be more than 0!');
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
      date: _date,
      note: note.isEmpty ? null : note,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SegmentedButton(
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
              const SizedBox(height: 15),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              if (_type != 'transfer') ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Category'),
                ),
                const SizedBox(height: 10),
                CategoryGrid(
                  items: _currentCategories,
                  selected: _category,
                  onSelected: (name) => setState(() => _category = name),
                ),
                const SizedBox(height: 15),
              ],
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: Icon(Icons.calendar_today),
                label: Text('${_date.day}/${_date.month}/${_date.year}'),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 1),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
