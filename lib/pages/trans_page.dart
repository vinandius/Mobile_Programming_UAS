import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/month_provider.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_row.dart';
import 'add_transaction_page.dart';
import '../widgets/calendar_tab.dart';
import '../widgets/daily_tab.dart';
import '../widgets/monthly_tab.dart';
import '../widgets/note_tab.dart';
import '../widgets/total_tab.dart';

class TransPage extends ConsumerWidget {
  const TransPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthlySummaryProvider);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const MonthSelector(),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Calendar'),
              Tab(text: 'Month'),
              Tab(text: 'Total'),
              Tab(text: 'Note'),
            ],
          ),
        ),
        body: Column(
          children: [
            SummaryRow(summary: summary),
            const Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  DailyTab(),
                  CalendarTab(),
                  MonthlyTab(),
                  TotalTab(),
                  NoteTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
