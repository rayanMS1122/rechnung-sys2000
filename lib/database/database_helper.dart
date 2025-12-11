import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mydb.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    """
    CREATE TABLE firma (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      strasse TEXT,
      plz TEXT,
      ort TEXT,
      telefon TEXT,
      email TEXT,
      website TEXT,
    )
""";
  }

  // Insert
  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('receiptes', row);
  }

  // Query all
  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await instance.database;
    return await db.query('receiptes');
  }

  // Update
  Future<int> update(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update('receiptes', row, where: 'id = ?', whereArgs: [id]);
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('receiptes', where: 'id = ?', whereArgs: [id]);
  }
}
