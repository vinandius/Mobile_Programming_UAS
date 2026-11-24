import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/pages/settings_page.dart';
import 'package:money_manager/pages/trans_page.dart';
import 'package:money_manager/pages/stats_page.dart';
import 'package:money_manager/pages/accounts_page.dart';
import 'package:money_manager/pages/login.dart';
import 'package:money_manager/models/user.dart';
import 'package:money_manager/pages/account.dart';
import 'package:money_manager/providers/auth_provider.dart';

import './providers/nav_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Manager',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color(0xFF00897B)),
      ),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final List<Widget> halaman = const [
    TransPage(),
    StatsPage(),
    AccountsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      body: halaman[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navIndexProvider.notifier).setIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            label: 'Trans',
          ),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Stats'),
          NavigationDestination(
            icon: Icon(Icons.monetization_on_outlined),
            label: 'Accounts',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
