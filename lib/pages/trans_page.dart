import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbldatepicker/tbldatepicker.dart';

import '../providers/transaction_provider.dart';

class TransPage extends ConsumerWidget {
  const TransPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
            Text('Nov 2026'),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
          ],
        ),
      ),
      body: SafeArea(),
    );
  }
}
