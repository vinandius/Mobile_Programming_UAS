class Accounts {
  final int? id;
  final int userId;
  final String name;
  final int initialBalance;

  Accounts({
    this.id,
    required this.userId,
    required this.name,
    this.initialBalance = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'initial_balance': initialBalance,
    };
  }

  factory Accounts.fromMap(Map<String, dynamic> map) {
    return Accounts(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      initialBalance: map['initialBalance'] as int,
    );
  }
}
