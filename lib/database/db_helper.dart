import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/transaction.dart';
import '../models/user.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Future<Database>? _opening;

  Future<Database> get database => _opening ??= _initDb();

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(dir.path).create(recursive: true);
    final path = p.join(dir.path, 'money_manager.db');

    final db = sqlite3.open(path);

    db.execute('PRAGMA foreign_keys = ON');

    _migrate(db);
    return db;
  }

  void _migrate(Database db) {
    final version = db.select('PRAGMA user_version').first.values.first as int;

    if (version < 1) {
      db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');

      db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          nominal INTEGER NOT NULL,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      db.execute('PRAGMA user_version = 1');
    }
  }

  String _hash(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> register(String name, String email, String password) async {
    final db = await database;
    try {
      db.execute('INSERT INTO users (name, email, password) VALUES (?, ?, ?)', [
        name,
        email,
        _hash(password),
      ]);
      return true;
    } on SqliteException {
      return false;
    }
  }

  Future<User?> login(String email, String password) async {
    final db = await database;
    final result = db.select(
      'SELECT * FROM users WHERE email = ? AND password = ?',
      [email, _hash(password)],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<void> addTransaction(Transaction t) async {
    final db = await database;
    db.execute(
      '''
      INSERT INTO transactions
        (user_id, title, nominal, type, category, date, note)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        t.userId,
        t.title,
        t.nominal,
        t.type,
        t.category,
        t.date.toIso8601String(),
        t.note,
      ],
    );
  }

  Future<List<Transaction>> getTransactions(int userId) async {
    final db = await database;
    final result = db.select(
      'SELECT * FROM transactions WHERE user_id = ? ORDER BY date DESC',
      [userId],
    );
    return result.map((row) => Transaction.fromMap(row)).toList();
  }

  Future<void> editTransactions(Transaction t) async {
    final db = await database;
    db.execute(
      '''
      UPDATE transactions
      SET title = ?, nominal = ?, type = ?, category = ?, date = ?, note = ?
      WHERE id = ?
      ''',
      [
        t.title,
        t.nominal,
        t.type,
        t.category,
        t.date.toIso8601String(),
        t.note,
        t.id,
      ],
    );
  }

  Future<void> deleteTransactions(int id) async {
    final db = await database;
    db.execute('DELETE FROM transactions WHERE id = ?', [id]);
  }
}
