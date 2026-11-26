import 'package:flutter/material.dart';

import '../providers/stats_provider.dart';

class StatsmodeSelector extends StatelessWidget {
  final StatsMode value;
  final ValueChanged<StatsMode> onChanged;

  const StatsmodeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _labels = {
    StatsMode.weekly: 'Weekly',
    StatsMode.monthly: 'Monthly',
    StatsMode.annually: 'Annually',
    StatsMode.period: 'Period',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StatsMode>(
          value: value,
          isDense: true,
          iconEnabledColor: Colors.white,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          style: TextStyle(color: Colors.black),
          selectedItemBuilder: (context) => [
            for (final m in StatsMode.values)
              Center(
                child: Text(_labels[m]!, style: TextStyle(color: Colors.white)),
              ),
          ],
          items: [
            for (final m in StatsMode.values)
              DropdownMenuItem(value: m, child: Text(_labels[m]!)),
          ],
          onChanged: (m) {
            if (m != null) onChanged(m);
          },
        ),
      ),
    );
  }
}
