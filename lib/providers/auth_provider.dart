import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void login(User user) => state = user;
  void logout() => state = null;
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
);
