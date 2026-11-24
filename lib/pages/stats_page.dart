import 'package:flutter/material.dart';

import '../widgets/month_selector.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const MonthSelector()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(child: Text('Ini adalah history page')),
        ),
      ),
    );
  }
}
