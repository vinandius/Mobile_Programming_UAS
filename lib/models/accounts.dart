class Accounts {
  final int? id;
  final int userId;
  final String name;
  final String group;
  final int initialBalance;

  Accounts({
    this.id,
    required this.userId,
    required this.name,
    this.group = 'Account',
    this.initialBalance = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'group_type': group,
      'initial_balance': initialBalance,
    };
  }

  factory Accounts.fromMap(Map<String, dynamic> map) {
    return Accounts(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      group: (map['group_type'] as String?) ?? 'Account',
      initialBalance: map['initial_balance'] as int,
    );
  }
}
