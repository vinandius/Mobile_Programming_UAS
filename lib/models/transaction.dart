class Transaction {
  final int? id;
  final int userId;
  final String title;
  final int nominal;
  final String type;
  final String category;
  final DateTime date;
  final String? note;
  final int accountId;
  final int? toAccountId;

  Transaction({
    this.id,
    required this.userId,
    required this.title,
    required this.nominal,
    required this.type,
    required this.category,
    required this.date,
    required this.accountId,
    this.toAccountId,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'nominal': nominal,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'account_id': accountId,
      'to_account_id': toAccountId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      nominal: map['nominal'] as int,
      type: map['type'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      accountId: map['account_id'] as int,
      toAccountId: map['to_account_id'] as int?,
    );
  }
}
