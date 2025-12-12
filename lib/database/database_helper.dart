import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbName = 'assets/test_DB/test';
      final path = join(dbPath, dbName);

      debugPrint('Datenbank-Pfad: $path');

      // Prüfen ob Datenbank bereits existiert
      final exists = await databaseExists(path);
      debugPrint('Datenbank existiert: $exists');

      // Datenbank öffnen/erstellen
      final db = await openDatabase(
        path,
        version: 2, // Version erhöht für neue Felder
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );

      debugPrint('Datenbank erfolgreich geöffnet');
      return db;
    } catch (e) {
      debugPrint('Fehler bei Datenbank-Initialisierung: $e');
      rethrow;
    }
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
    await db.execute('''
  CREATE TABLE einstellungen (
    id INTEGER PRIMARY KEY CHECK (id = 1),  -- Nur eine Zeile erlauben
    firma_name TEXT,
    firma_strasse TEXT,
    firma_plz TEXT,
    firma_ort TEXT,
    firma_telefon TEXT,
    firma_email TEXT,
    firma_website TEXT,
    
    baustelle_strasse TEXT,
    baustelle_plz TEXT,
    baustelle_ort TEXT,
    
    logo_path TEXT,
    enable_editing INTEGER DEFAULT 0,  -- 0 = false, 1 = true
    
    last_monteur_id INTEGER,  -- ID des zuletzt ausgewählten Monteurs
    last_kunde_id INTEGER     -- ID des zuletzt ausgewählten Kunden
  )
''');
  }

// NEU: Wird aufgerufen, wenn Version von 1 auf 2 erhöht wird
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Neue Spalten zur bestehenden Tabelle hinzufügen
      try {
        await db.execute('ALTER TABLE einstellungen ADD COLUMN last_monteur_id INTEGER');
        await db.execute('ALTER TABLE einstellungen ADD COLUMN last_kunde_id INTEGER');
        debugPrint('Datenbank erfolgreich auf Version 2 aktualisiert');
      } catch (e) {
        debugPrint('Fehler beim Upgrade der Datenbank: $e');
        // Falls ALTER TABLE fehlschlägt (z.B. Spalten existieren bereits), ignorieren
      }
    }
  }

// Speichert oder aktualisiert die Einstellungen (upsert)
  Future<void> saveEinstellungen(Map<String, dynamic> data) async {
    final db = await instance.database;

    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM einstellungen'));

    if (count == 0) {
      // Erste Speicherung
      data['id'] = 1;
      await db.insert('einstellungen', data);
    } else {
      // Update bestehende Zeile
      await db.update('einstellungen', data, where: 'id = 1');
    }
  }

// Lädt alle Einstellungen
  Future<Map<String, dynamic>?> getEinstellungen() async {
    final db = await instance.database;
    final result = await db.query('einstellungen', where: 'id = 1');
    return result.isNotEmpty ? result.first : null;
  }

  // ====================== FIRMA ======================
  Future<int> insertFirma(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = await db.insert('firma', row);
      debugPrint('Firma gespeichert mit ID: $id');
      return id;
    } catch (e) {
      debugPrint('Fehler beim Speichern der Firma: $e');
      rethrow;
    }
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
    try {
      final db = await instance.database;
      final id = await db.insert('kunde', row);
      debugPrint('Kunde gespeichert mit ID: $id');
      return id;
    } catch (e) {
      debugPrint('Fehler beim Speichern des Kunden: $e');
      rethrow;
    }
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
    try {
      final db = await instance.database;
      final id = await db.insert('monteur', row);
      debugPrint('Monteur gespeichert mit ID: $id');
      return id;
    } catch (e) {
      debugPrint('Fehler beim Speichern des Monteurs: $e');
      rethrow;
    }
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
    try {
      final db = await instance.database;
      final id = await db.insert('baustelle', row);
      debugPrint('Baustelle gespeichert mit ID: $id');
      return id;
    } catch (e) {
      debugPrint('Fehler beim Speichern der Baustelle: $e');
      rethrow;
    }
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
    if (kDebugMode) {
      final firmen = await queryAllFirmen();
      final kunden = await queryAllKunden();
      final monteure = await queryAllMonteure();
      final baustellen = await queryAllBaustellen();

      debugPrint('=== Firmen (${firmen.length}) ===');
      for (var f in firmen) debugPrint(f.toString());

      debugPrint('=== Kunden (${kunden.length}) ===');
      for (var k in kunden) debugPrint(k.toString());

      debugPrint('=== Monteure (${monteure.length}) ===');
      for (var m in monteure) debugPrint(m.toString());

      debugPrint('=== Baustellen (${baustellen.length}) ===');
      for (var b in baustellen) debugPrint(b.toString());
    }
  }
}
