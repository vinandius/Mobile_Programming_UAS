import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/accounts.dart';
import '../models/transaction.dart';
import '../models/user.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Future<Database>? _opening;

  static const defaultAccounts = ['Cash', 'Account', 'Card'];

  Future<Database> get database => _opening ??= _initDb();

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(dir.path).create(recursive: true);
    final db = sqlite3.open(p.join(dir.path, 'money_manager.db'));

    db.execute('PRAGMA foreign_keys = ON');
    _migrate(db);
    return db;
  }

  void _migrate(Database db) {
    final version = db.select('PRAGMA user_version').first.values.first as int;

    if (version < 2) {
      db.execute('BEGIN');
      try {
        db.execute('DROP TABLE IF EXISTS transactions');
        db.execute('DROP TABLE IF EXISTS accounts');
        db.execute('DROP TABLE IF EXISTS users');

        db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');

        db.execute('''
          CREATE TABLE accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            initial_balance INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users (id)
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
            account_id INTEGER NOT NULL,
            to_account_id INTEGER,
            FOREIGN KEY (user_id) REFERENCES users (id),
            FOREIGN KEY (account_id) REFERENCES accounts (id),
            FOREIGN KEY (to_account_id) REFERENCES accounts (id)
          )
        ''');

        db.execute('PRAGMA user_version = 2');
        db.execute('COMMIT');
      } catch (e) {
        db.execute('ROLLBACK');
        rethrow;
      }
    }

    if (version < 3) {
      db.execute('BEGIN');
      try {
        db.execute(
          "ALTER TABLE accounts ADD COLUMN group_type TEXT NOT NULL DEFAULT 'Account'",
        );
        db.execute(
          "UPDATE accounts SET group_type = 'Cash' WHERE name = 'Cash'",
        );
        db.execute(
          "UPDATE accounts SET group_type = 'Card' WHERE name = 'Card'",
        );
        db.execute('PRAGMA user_version = 3');
        db.execute('COMMIT');
      } catch (e) {
        db.execute('ROLLBACK');
        rethrow;
      }
    }
  }

  String _hash(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> register(String name, String email, String password) async {
    final db = await database;
    try {
      db.execute('BEGIN');
      db.execute('INSERT INTO users (name, email, password) VALUES (?, ?, ?)', [
        name,
        email,
        _hash(password),
      ]);
      final userId = db.lastInsertRowId;

      for (final accountName in defaultAccounts) {
        db.execute(
          'INSERT INTO accounts (user_id, name, group_type) VALUES (?, ?, ?)',
          [userId, accountName, accountName],
        );
      }
      db.execute('COMMIT');
      return true;
    } on SqliteException {
      db.execute('ROLLBACK');
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

  Future<List<Accounts>> getAccounts(int userId) async {
    final db = await database;
    const query = 'SELECT * FROM accounts WHERE user_id = ? ORDER BY id';

    var result = db.select(query, [userId]);

    if (result.isEmpty) {
      for (final accountName in defaultAccounts) {
        db.execute(
          'INSERT INTO accounts (user_id, name, group_type) VALUES (?, ?, ?)',
          [userId, accountName, accountName],
        );
      }
      result = db.select(query, [userId]);
    }

    return result.map((row) => Accounts.fromMap(row)).toList();
  }

  Future<void> addAccount(Accounts a) async {
    final db = await database;
    db.execute(
      '''
      INSERT INTO accounts (user_id, name, group_type, initial_balance)
      VALUES (?, ?, ?, ?)
      ''',
      [a.userId, a.name, a.group, a.initialBalance],
    );
  }

  Future<void> editAccount(Accounts a) async {
    final db = await database;
    db.execute(
      '''
      UPDATE accounts
      SET name = ?, group_type = ?, initial_balance = ?
      WHERE id = ?
      ''',
      [a.name, a.group, a.initialBalance, a.id],
    );
  }

  Future<void> deleteAccount(int accountId) async {
    final db = await database;
    db.execute('BEGIN');
    try {
      db.execute(
        'DELETE FROM transactions WHERE account_id = ? OR to_account_id = ?',
        [accountId, accountId],
      );
      db.execute('DELETE FROM accounts WHERE id = ?', [accountId]);
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> addTransaction(Transaction t) async {
    final db = await database;
    db.execute(
      '''
      INSERT INTO transactions
        (user_id, title, nominal, type, category, date, note,
        account_id, to_account_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        t.userId,
        t.title,
        t.nominal,
        t.type,
        t.category,
        t.date.toIso8601String(),
        t.note,
        t.accountId,
        t.toAccountId,
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
      SET title = ?, nominal = ?, type = ?, category = ?, date = ?,
          note = ?, account_id = ?, to_account_id = ?
      WHERE id = ?
      ''',
      [
        t.title,
        t.nominal,
        t.type,
        t.category,
        t.date.toIso8601String(),
        t.note,
        t.accountId,
        t.toAccountId,
        t.id,
      ],
    );
  }

  Future<void> deleteTransactions(int id) async {
    final db = await database;
    db.execute('DELETE FROM transactions WHERE id = ?', [id]);
  }
}
