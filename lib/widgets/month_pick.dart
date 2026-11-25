import 'package:flutter/material.dart';

import '../utils/helpers.dart';

class MonthPickDialog extends StatefulWidget {
  final DateTime initial;
  const MonthPickDialog({super.key, required this.initial});

  @override
  State<MonthPickDialog> createState() => _MonthPickDialogState();
}

class _MonthPickDialogState extends State<MonthPickDialog> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => setState(() => _year--),
          ),
          Text('$_year'),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => setState(() => _year++),
          ),
        ],
      ),
      content: SizedBox(
        width: 280,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (var m = 1; m <= 12; m++) _monthCell(m, primary)],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Widget _monthCell(int m, Color primary) {
    final selected = _year == widget.initial.year && m == widget.initial.month;

    return SizedBox(
      width: 84,
      height: 44,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () => Navigator.pop(context, DateTime(_year, m)),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? primary : null,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            monthsName[m - 1],
            style: TextStyle(color: selected ? Colors.white : null),
          ),
        ),
      ),
    );
  }
}
