import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('assets/test_DB/test');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabelle Firma
    await db.execute('''
      CREATE TABLE firma (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        strasse TEXT,
        plz TEXT,
        ort TEXT,
        telefon TEXT,
        email TEXT,
        website TEXT
      )
    ''');

    // Tabelle Kunde
    await db.execute('''
      CREATE TABLE kunde (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        strasse TEXT,
        plz TEXT,
        ort TEXT,
        telefon TEXT,
        email TEXT
      )
    ''');

    // Tabelle Monteur
    await db.execute('''
      CREATE TABLE monteur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vorname TEXT,
        nachname TEXT,
        telefon TEXT,
        email TEXT
      )
    ''');

    // Tabelle Baustelle
    await db.execute('''
      CREATE TABLE baustelle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        strasse TEXT,
        plz TEXT,
        ort TEXT
      )
    ''');
  }

  // ====================== FIRMA ======================
  Future<int> insertFirma(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('firma', row);
  }

  Future<List<Map<String, dynamic>>> queryAllFirmen() async {
    final db = await instance.database;
    return await db.query('firma');
  }

  Future<Map<String, dynamic>?> queryFirmaById(int id) async {
    final db = await instance.database;
    final result = await db.query('firma', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateFirma(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'] as int;
    return await db.update('firma', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFirma(int id) async {
    final db = await instance.database;
    return await db.delete('firma', where: 'id = ?', whereArgs: [id]);
  }

  // ====================== KUNDE ======================
  Future<int> insertKunde(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('kunde', row);
  }

  Future<List<Map<String, dynamic>>> queryAllKunden() async {
    final db = await instance.database;
    return await db.query('kunde');
  }

  Future<Map<String, dynamic>?> queryKundeById(int id) async {
    final db = await instance.database;
    final result = await db.query('kunde', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateKunde(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'] as int;
    return await db.update('kunde', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteKunde(int id) async {
    final db = await instance.database;
    return await db.delete('kunde', where: 'id = ?', whereArgs: [id]);
  }

  // ====================== MONTEUR ======================
  Future<int> insertMonteur(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('monteur', row);
  }

  Future<List<Map<String, dynamic>>> queryAllMonteure() async {
    final db = await instance.database;
    return await db.query('monteur');
  }

  Future<Map<String, dynamic>?> queryMonteurById(int id) async {
    final db = await instance.database;
    final result = await db.query('monteur', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateMonteur(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'] as int;
    return await db.update('monteur', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMonteur(int id) async {
    final db = await instance.database;
    return await db.delete('monteur', where: 'id = ?', whereArgs: [id]);
  }

  // ====================== BAUSTELLE ======================
  Future<int> insertBaustelle(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('baustelle', row);
  }

  Future<List<Map<String, dynamic>>> queryAllBaustellen() async {
    final db = await instance.database;
    return await db.query('baustelle');
  }

  Future<Map<String, dynamic>?> queryBaustelleById(int id) async {
    final db = await instance.database;
    final result =
        await db.query('baustelle', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateBaustelle(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'] as int;
    return await db.update('baustelle', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBaustelle(int id) async {
    final db = await instance.database;
    return await db.delete('baustelle', where: 'id = ?', whereArgs: [id]);
  }

  // ====================== Hilfsfunktion zum Debuggen ======================
  Future<void> printAllData() async {
    final firmen = await queryAllFirmen();
    final kunden = await queryAllKunden();
    final monteure = await queryAllMonteure();
    final baustellen = await queryAllBaustellen();

    print('=== Firmen (${firmen.length}) ===');
    for (var f in firmen) print(f);

    print('=== Kunden (${kunden.length}) ===');
    for (var k in kunden) print(k);

    print('=== Monteure (${monteure.length}) ===');
    for (var m in monteure) print(m);

    print('=== Baustellen (${baustellen.length}) ===');
    for (var b in baustellen) print(b);
  }
}
