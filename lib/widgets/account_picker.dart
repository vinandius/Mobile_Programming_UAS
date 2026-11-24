import 'package:flutter/material.dart';

import '../models/accounts.dart';

class AccountPicker extends StatelessWidget {
  final String label;
  final List<Accounts> accounts;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  const AccountPicker({
    super.key,
    required this.label,
    required this.accounts,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: accounts.map((a) {
              return ChoiceChip(
                label: Text(a.name),
                selected: a.id == selectedId,
                onSelected: (_) => onSelected(a.id!),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
