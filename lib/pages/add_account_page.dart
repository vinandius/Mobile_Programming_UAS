import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/accounts.dart';

Future<Accounts?> showAccountDialog(
  BuildContext context, {
  required int userId,
  Accounts? existing,
}) {
  return showDialog<Accounts>(
    context: context,
    builder: (_) => _AccountDialog(userId: userId, existing: existing),
  );
}

class _AccountDialog extends StatefulWidget {
  final int userId;
  final Accounts? existing;

  const _AccountDialog({required this.userId, this.existing});

  @override
  State<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<_AccountDialog> {
  late final _nameCtrl = TextEditingController(
    text: widget.existing?.name ?? '',
  );

  late final _balanceCtrl = TextEditingController(
    text: (widget.existing?.initialBalance ?? 0).toString(),
  );

  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final balance = int.tryParse(_balanceCtrl.text.trim());

    if (name.isEmpty) {
      setState(() => _error = 'Account name is required!');
      return;
    }

    if (balance == null) {
      setState(() => _error = 'Balance must be a number');
      return;
    }

    Navigator.pop(
      context,
      Accounts(
        id: widget.existing?.id,
        userId: widget.userId,
        name: name,
        initialBalance: balance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add account' : 'Edit account'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: 'Account name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _balanceCtrl,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Initial balance',
                prefixText: 'Rp',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text('Save')),
      ],
    );
  }
}
