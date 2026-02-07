import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/master_password.dart';
import '../models/category.dart';
import '../models/password_entry.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      // On web, getDatabasesPath() is not supported; use the name directly.
      path = AppConstants.dbName;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, AppConstants.dbName);
    }

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMasterPassword} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableCategories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tablePasswordEntries} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        username TEXT,
        encrypted_password TEXT NOT NULL,
        encrypted_notes TEXT,
        url TEXT,
        category_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES ${AppConstants.tableCategories}(id) ON DELETE SET NULL
      )
    ''');

    // Seed default categories
    for (final cat in AppConstants.defaultCategories) {
      await db.insert(AppConstants.tableCategories, {
        'name': cat['name'],
        'icon': cat['icon'],
      });
    }
  }

  // Master Password methods
  Future<MasterPassword?> getMasterPassword() async {
    final db = await database;
    final results = await db.query(AppConstants.tableMasterPassword, limit: 1);
    if (results.isEmpty) return null;
    return MasterPassword.fromMap(results.first);
  }

  Future<int> insertMasterPassword(MasterPassword mp) async {
    final db = await database;
    return await db.insert(AppConstants.tableMasterPassword, mp.toMap());
  }

  Future<int> updateMasterPassword(MasterPassword mp) async {
    final db = await database;
    return await db.update(
      AppConstants.tableMasterPassword,
      mp.toMap(),
      where: 'id = ?',
      whereArgs: [mp.id],
    );
  }

  // Category methods
  Future<List<Category>> getCategories() async {
    final db = await database;
    final results = await db.query(AppConstants.tableCategories, orderBy: 'name ASC');
    return results.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(AppConstants.tableCategories, category.toMap());
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Password Entry methods
  Future<List<PasswordEntry>> getPasswordEntries() async {
    final db = await database;
    final results = await db.query(
      AppConstants.tablePasswordEntries,
      orderBy: 'updated_at DESC',
    );
    return results.map((map) => PasswordEntry.fromMap(map)).toList();
  }

  Future<PasswordEntry?> getPasswordEntry(int id) async {
    final db = await database;
    final results = await db.query(
      AppConstants.tablePasswordEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return PasswordEntry.fromMap(results.first);
  }

  Future<int> insertPasswordEntry(PasswordEntry entry) async {
    final db = await database;
    return await db.insert(AppConstants.tablePasswordEntries, entry.toMap());
  }

  Future<int> updatePasswordEntry(PasswordEntry entry) async {
    final db = await database;
    return await db.update(
      AppConstants.tablePasswordEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deletePasswordEntry(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tablePasswordEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PasswordEntry>> getPasswordEntriesByCategory(int categoryId) async {
    final db = await database;
    final results = await db.query(
      AppConstants.tablePasswordEntries,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'updated_at DESC',
    );
    return results.map((map) => PasswordEntry.fromMap(map)).toList();
  }
}
