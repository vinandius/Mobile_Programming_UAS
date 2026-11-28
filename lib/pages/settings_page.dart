import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/month_provider.dart';
import '../providers/nav_provider.dart';
import '../widgets/section_card.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';
import 'login.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(currentUserProvider.notifier).logout();
    ref.invalidate(navIndexProvider);
    ref.invalidate(selectedMonthProvider);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final name = user?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        children: [
          SectionCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primary.withValues(alpha: 0.12),
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SectionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Change email'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangeEmailPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          SectionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _logout(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
