class Transactions {
  final int? id;
  final int userId;
  final String title;
  final int nominal;
  final String type;
  final String category;
  final DateTime date;
  final String? note;

  Transactions({
    this.id,
    required this.userId,
    required this.title,
    required this.nominal,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
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
    };
  }

  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      title: map['title'] as String,
      nominal: map['nominal'] as int,
      type: map['type'] as String,
      category: map['category'] as String,
      date: map['date'] as DateTime,
      note: map['note'] as String,
    );
  }
}
