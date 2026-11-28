import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/db_helper.dart';
import '../providers/auth_provider.dart';

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool _saving = false;
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final newEmail = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim(); // sama seperti login & register

    if (newEmail.isEmpty || password.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }
    if (!_emailRegex.hasMatch(newEmail)) {
      setState(() => _error = 'Invalid email format');
      return;
    }
    if (newEmail.toLowerCase() == user.email.toLowerCase()) {
      setState(() => _error = 'This is already your current email');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final result = await DbHelper.instance.changeEmail(
      userId: user.id!,
      newEmail: newEmail,
      password: password,
    );

    if (!mounted) return;

    switch (result) {
      case ChangeEmailResult.wrongPassword:
        setState(() {
          _saving = false;
          _error = 'Wrong password';
        });
      case ChangeEmailResult.emailTaken:
        setState(() {
          _saving = false;
          _error = 'Email is already used by another account';
        });
      case ChangeEmailResult.success:
        ref.read(currentUserProvider.notifier).updateEmail(newEmail);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Email updated')));
        Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16, child: Text('New Email')),
              const SizedBox(height: 5),
              SizedBox(width: 32),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              const SizedBox(height: 16, child: Text('Your Password')),
              const SizedBox(height: 5),
              SizedBox(width: 32),
              TextField(
                controller: _passwordCtrl,
                obscureText: _hide,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _hide = !_hide),
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
