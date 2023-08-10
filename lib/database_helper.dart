import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper.internal();

  //late Database _database;
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'socogov_soco.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE stafftry( id INTEGER PRIMARY KEY AUTOINCREMENT, fname TEXT, lname TEXT, unique (fname, lname))',
    );
  }

  // Insert data into the local database
  Future<int> insertOrReplaceData(Map<String, dynamic> data) async {
    Database? db = await database;
    return await db!
        .insert('stafftry', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve data from the local database
  Future<List<Map<String, dynamic>>> getData() async {
    Database? db = await database;
    return await db!.query('stafftry');
  }

  // ... Add other methods for updating, deleting, or querying data

  //this function will delete a row from the table
  Future<void> deleteAllData() async {
    final db = await database;
    await db!.delete('stafftry');
  }
}
