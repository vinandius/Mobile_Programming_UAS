import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void login(User user) => state = user;
  void logout() => state = null;

  void updateEmail(String email) {
    final u = state;
    if (u == null) return;
    state = User(id: u.id, name: u.name, email: email, password: u.password);
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
);
