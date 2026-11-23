import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbldatepicker/tbldatepicker.dart';

import '../providers/transaction_provider.dart';

import '../widgets/summary_card.dart';

class TransPage extends ConsumerWidget {
  const TransPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(children: [const SummaryCard()]),
        ),
      ),
    );
  }
}
