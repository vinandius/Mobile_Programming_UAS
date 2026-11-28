import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../providers/auth_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _saving = false;
  bool _hide = true;
  bool _hide1 = true;
  bool _hide2 = true;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final current = _currentCtrl.text.trim();
    final newPass = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'New passwords do not match');
      return;
    }
    if (newPass == current) {
      setState(
        () => _error = 'New password must be different from the current one',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final result = await DbHelper.instance.changePassword(
      userId: user.id!,
      currentPassword: current,
      newPassword: newPass,
    );

    if (result == ChangePasswordResult.wrongPassword) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Current password is wrong';
      });
      return;
    }

    final fresh = await DbHelper.instance.login(user.email, newPass);

    if (!mounted) return;
    if (fresh != null) {
      ref.read(currentUserProvider.notifier).login(fresh);
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Password updated')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(width: 120, child: Text('Current Password')),
              SizedBox(height: 5),
              SizedBox(width: 32),
              TextField(
                controller: _currentCtrl,
                obscureText: _hide,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _hide = !_hide),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const SizedBox(height: 16, child: Text('New Password')),
              const SizedBox(height: 5),
              SizedBox(width: 32),
              TextField(
                controller: _newCtrl,
                obscureText: _hide1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hide1 ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _hide1 = !_hide1),
                  ),
                ),
              ),
              SizedBox(height: 15),
              const SizedBox(height: 16, child: Text('Confirm New Password')),
              SizedBox(height: 5),
              SizedBox(width: 32),
              TextField(
                controller: _confirmCtrl,
                obscureText: _hide2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hide2 ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _hide2 = !_hide2),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
