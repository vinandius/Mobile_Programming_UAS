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
      'account_id': accountId,
      'to_account_id': toAccountId,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      title: map['title'] as String,
      nominal: map['nominal'] as int,
      type: map['type'] as String,
      category: map['category'] as String,
      date: map['date'] as DateTime,
      accountId: map['account_id'] as int,
      toAccountId: map['to_account_id'] as int?,
      note: map['note'] as String?,
    );
  }
}
