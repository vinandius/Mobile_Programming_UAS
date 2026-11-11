import 'package:flutter/material.dart';
import 'package:money_manager/pages/homepage.dart';
import 'package:money_manager/pages/history.dart';
import 'package:money_manager/pages/Statistics.dart';
import 'package:money_manager/pages/login.dart';
import 'package:money_manager/pages/register.dart';
import 'package:money_manager/models/User.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color(0xFF00897B)),
      ),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.user});
  final User user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  final List<Widget> halaman = const [Homepage(), History(), Statistics()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00897B),
        title: Text("Hello ${widget.user.name}"),
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
