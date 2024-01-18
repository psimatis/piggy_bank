import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'piggy_bank.db');
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE balance_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL
      )
    ''');
  }

  Future<void> insertBalance(double amount) async {
    final Database db = await database;
    await db.insert(
      'balance_history',
      {'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<double>> getBalanceHistory() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('balance_history');
    return List.generate(maps.length, (i) => maps[i]['amount'] as double);
  }
}
