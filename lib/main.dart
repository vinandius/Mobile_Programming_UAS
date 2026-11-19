import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/pages/homepage.dart';
import 'package:money_manager/pages/history.dart';
import 'package:money_manager/pages/Statistics.dart';
import 'package:money_manager/pages/login.dart';
import 'package:money_manager/models/user.dart';
import 'package:money_manager/pages/account.dart';
import 'package:money_manager/providers/auth_provider.dart';

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
  int currentIndex = 0;

  final List<Widget> halaman = const [Homepage(), History(), Statistics()];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00897B),
        title: Text("Hello ${user?.name ?? ''}"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Account()),
              );
            },
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF5F7F8),
      body: halaman[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}
