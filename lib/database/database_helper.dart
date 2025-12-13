import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Tabellennamen als Konstanten
  static const String _tableFirma = 'firma';
  static const String _tableKunde = 'kunde';
  static const String _tableMonteur = 'monteur';
  static const String _tableBaustelle = 'baustelle';
  static const String _tableEinstellungen = 'einstellungen';

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

      // Foreign Keys aktivieren (SQLite erfordert explizite Aktivierung)
      await db.execute('PRAGMA foreign_keys = ON');

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
      CREATE TABLE $_tableFirma (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        strasse TEXT,
        plz TEXT,
        ort TEXT,
        telefon TEXT,
        email TEXT,
        website TEXT
      )
    ''');

    // Index für Firma.name für schnellere Suche
    await db.execute('CREATE INDEX IF NOT EXISTS idx_firma_name ON $_tableFirma(name)');

    // Tabelle Kunde
    await db.execute('''
      CREATE TABLE $_tableKunde (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        strasse TEXT,
        plz TEXT,
        ort TEXT,
        telefon TEXT,
        email TEXT
      )
    ''');

    // Indizes für Kunde für schnellere Suche
    await db.execute('CREATE INDEX IF NOT EXISTS idx_kunde_name ON $_tableKunde(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_kunde_plz_ort ON $_tableKunde(plz, ort)');

    // Tabelle Monteur
    await db.execute('''
      CREATE TABLE $_tableMonteur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vorname TEXT NOT NULL,
        nachname TEXT NOT NULL,
        telefon TEXT,
        email TEXT
      )
    ''');

    // Index für Monteur für schnellere Suche
    await db.execute('CREATE INDEX IF NOT EXISTS idx_monteur_name ON $_tableMonteur(vorname, nachname)');

    // Tabelle Baustelle (mit Foreign Key zu Kunde für Datenintegrität)
    await db.execute('''
      CREATE TABLE $_tableBaustelle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kunde_id INTEGER,
        strasse TEXT,
        plz TEXT,
        ort TEXT,
        FOREIGN KEY (kunde_id) REFERENCES $_tableKunde(id) ON DELETE SET NULL
      )
    ''');

    // Index für Baustelle
    await db.execute('CREATE INDEX IF NOT EXISTS idx_baustelle_kunde ON $_tableBaustelle(kunde_id)');

    // Tabelle Einstellungen
    await db.execute('''
      CREATE TABLE $_tableEinstellungen (
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

// Wird aufgerufen, wenn Datenbank-Version erhöht wird (schrittweise Upgrades)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Datenbank-Upgrade von Version $oldVersion auf $newVersion');
    
    // Transaktion für konsistente Upgrades
    await db.transaction((txn) async {
      // Schrittweise Upgrades durchführen
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        switch (version) {
          case 2:
            // Upgrade auf Version 2: Neue Spalten für letzte Auswahl
            try {
              await txn.execute('ALTER TABLE $_tableEinstellungen ADD COLUMN last_monteur_id INTEGER');
              await txn.execute('ALTER TABLE $_tableEinstellungen ADD COLUMN last_kunde_id INTEGER');
              debugPrint('Datenbank erfolgreich auf Version 2 aktualisiert');
            } catch (e) {
              debugPrint('Fehler beim Upgrade auf Version 2: $e');
              // Falls Spalten bereits existieren, ignorieren
            }
            break;
          // Hier können zukünftige Upgrades hinzugefügt werden:
          // case 3:
          //   await txn.execute('...');
          //   break;
          default:
            debugPrint('Unbekannte Datenbank-Version: $version');
        }
      }
    });
  }

// Speichert oder aktualisiert die Einstellungen (upsert) mit Transaktion
  Future<void> saveEinstellungen(Map<String, dynamic> data) async {
    final db = await instance.database;
    
    try {
      await db.transaction((txn) async {
        final count = Sqflite.firstIntValue(
          await txn.rawQuery('SELECT COUNT(*) FROM $_tableEinstellungen'),
        );
        
        if (count == 0) {
          // Erste Speicherung
          data['id'] = 1;
          await txn.insert(_tableEinstellungen, data);
        } else {
          // Update bestehende Zeile
          await txn.update(_tableEinstellungen, data, where: 'id = ?', whereArgs: [1]);
        }
      });
    } catch (e) {
      debugPrint('Fehler beim Speichern der Einstellungen: $e');
      rethrow;
    }
  }

// Lädt alle Einstellungen
  Future<Map<String, dynamic>?> getEinstellungen() async {
    try {
      final db = await instance.database;
      final result = await db.query(_tableEinstellungen, where: 'id = ?', whereArgs: [1]);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Fehler beim Laden der Einstellungen: $e');
      return null;
    }
  }

  // Schließt die Datenbank ordnungsgemäß
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('Datenbank geschlossen');
    }
  }

  // ====================== FIRMA ======================
  Future<int> insertFirma(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = await db.insert(_tableFirma, row);
      debugPrint('Firma gespeichert mit ID: $id');
      return id;
    } catch (e) {
      debugPrint('Fehler beim Speichern der Firma: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryAllFirmen() async {
    final db = await instance.database;
    return await db.query(_tableFirma);
  }

  Future<Map<String, dynamic>?> queryFirmaById(int id) async {
    final db = await instance.database;
    final result = await db.query(_tableFirma, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateFirma(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = row['id'] as int;
      if (id <= 0) throw Exception('Ungültige ID für Update');
      return await db.update(_tableFirma, row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Fehler beim Aktualisieren der Firma: $e');
      rethrow;
    }
  }

  Future<int> deleteFirma(int id) async {
    try {
      final db = await instance.database;
      if (id <= 0) throw Exception('Ungültige ID für Löschung');
      return await db.delete(_tableFirma, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Fehler beim Löschen der Firma: $e');
      rethrow;
    }
  }

  // ====================== KUNDE ======================
  Future<int> insertKunde(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = await db.insert(_tableKunde, row);
      debugPrint('Kunde gespeichert mit ID: $id');
      return id;
    } catch (e) {
      debugPrint('Fehler beim Speichern des Kunden: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryAllKunden() async {
    final db = await instance.database;
    return await db.query(_tableKunde);
  }

  Future<Map<String, dynamic>?> queryKundeById(int id) async {
    final db = await instance.database;
    final result = await db.query(_tableKunde, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateKunde(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = row['id'] as int;
      if (id <= 0) throw Exception('Ungültige ID für Update');
      return await db.update(_tableKunde, row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Fehler beim Aktualisieren des Kunden: $e');
      rethrow;
    }
  }

  Future<int> deleteKunde(int id) async {
    try {
      final db = await instance.database;
      if (id <= 0) throw Exception('Ungültige ID für Löschung');
      return await db.delete(_tableKunde, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Fehler beim Löschen des Kunden: $e');
      rethrow;
    }
  }

  // Prüft ob ein identischer Kunde bereits existiert (optimiert mit SQL-Query)
  // Werte werden vorher normalisiert für bessere Performance
  Future<bool> kundeExists(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final name = (row['name']?.toString() ?? '').trim().toLowerCase();
      final plz = (row['plz']?.toString() ?? '').trim().toLowerCase();
      final ort = (row['ort']?.toString() ?? '').trim().toLowerCase();
      final telefon = (row['telefon']?.toString() ?? '').trim().toLowerCase();
      final email = (row['email']?.toString() ?? '').trim().toLowerCase();
      
      // Prüfe auf identischen Kunden: Name + PLZ + Ort
      if (name.isNotEmpty && plz.isNotEmpty && ort.isNotEmpty) {
        final result = await db.rawQuery(
          'SELECT id FROM $_tableKunde WHERE LOWER(name) = ? AND LOWER(plz) = ? AND LOWER(ort) = ? LIMIT 1',
          [name, plz, ort],
        );
        if (result.isNotEmpty) return true;
      }
      
      // Prüfe auf identischen Kunden: Name + Telefon
      if (name.isNotEmpty && telefon.isNotEmpty) {
        final result = await db.rawQuery(
          'SELECT id FROM $_tableKunde WHERE LOWER(name) = ? AND LOWER(telefon) = ? LIMIT 1',
          [name, telefon],
        );
        if (result.isNotEmpty) return true;
      }
      
      // Prüfe auf identischen Kunden: Name + Email
      if (name.isNotEmpty && email.isNotEmpty) {
        final result = await db.rawQuery(
          'SELECT id FROM $_tableKunde WHERE LOWER(name) = ? AND LOWER(email) = ? LIMIT 1',
          [name, email],
        );
        if (result.isNotEmpty) return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Fehler bei kundeExists: $e');
      return false;
    }
  }

  // ====================== MONTEUR ======================
  Future<int> insertMonteur(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = await db.insert(_tableMonteur, row);
      debugPrint('Monteur gespeichert mit ID: $id');
      return id;
    } catch (e) {
      debugPrint('Fehler beim Speichern des Monteurs: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryAllMonteure() async {
    final db = await instance.database;
    return await db.query(_tableMonteur);
  }

  Future<Map<String, dynamic>?> queryMonteurById(int id) async {
    final db = await instance.database;
    final result = await db.query(_tableMonteur, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateMonteur(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = row['id'] as int;
      if (id <= 0) throw Exception('Ungültige ID für Update');
      return await db.update(_tableMonteur, row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Fehler beim Aktualisieren des Monteurs: $e');
      rethrow;
    }
  }

  Future<int> deleteMonteur(int id) async {
    try {
      final db = await instance.database;
      if (id <= 0) throw Exception('Ungültige ID für Löschung');
      return await db.delete(_tableMonteur, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Fehler beim Löschen des Monteurs: $e');
      rethrow;
    }
  }

  // Prüft ob ein identischer Monteur bereits existiert (optimiert mit SQL-Query)
  // Werte werden vorher normalisiert für bessere Performance
  Future<bool> monteurExists(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final vorname = (row['vorname']?.toString() ?? '').trim().toLowerCase();
      final nachname = (row['nachname']?.toString() ?? '').trim().toLowerCase();
      final telefon = (row['telefon']?.toString() ?? '').trim().toLowerCase();
      
      // Prüfe auf identischen Monteur: Vorname + Nachname
      if (vorname.isNotEmpty && nachname.isNotEmpty) {
        final result = await db.rawQuery(
          'SELECT id FROM $_tableMonteur WHERE LOWER(vorname) = ? AND LOWER(nachname) = ? LIMIT 1',
          [vorname, nachname],
        );
        if (result.isNotEmpty) return true;
      }
      
      // Prüfe auf identischen Monteur: Vorname + Nachname + Telefon
      if (vorname.isNotEmpty && nachname.isNotEmpty && telefon.isNotEmpty) {
        final result = await db.rawQuery(
          'SELECT id FROM $_tableMonteur WHERE LOWER(vorname) = ? AND LOWER(nachname) = ? AND LOWER(telefon) = ? LIMIT 1',
          [vorname, nachname, telefon],
        );
        if (result.isNotEmpty) return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Fehler bei monteurExists: $e');
      return false;
    }
  }

  // ====================== BAUSTELLE ======================
  Future<int> insertBaustelle(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = await db.insert(_tableBaustelle, row);
      debugPrint('Baustelle gespeichert mit ID: $id');
      return id;
    } catch (e) {
      debugPrint('Fehler beim Speichern der Baustelle: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryAllBaustellen() async {
    final db = await instance.database;
    return await db.query(_tableBaustelle);
  }

  Future<Map<String, dynamic>?> queryBaustelleById(int id) async {
    final db = await instance.database;
    final result =
        await db.query(_tableBaustelle, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateBaustelle(Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      final id = row['id'] as int;
      if (id <= 0) throw Exception('Ungültige ID für Update');
      return await db.update(_tableBaustelle, row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Fehler beim Aktualisieren der Baustelle: $e');
      rethrow;
    }
  }

  Future<int> deleteBaustelle(int id) async {
    try {
      final db = await instance.database;
      if (id <= 0) throw Exception('Ungültige ID für Löschung');
      return await db.delete(_tableBaustelle, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Fehler beim Löschen der Baustelle: $e');
      rethrow;
    }
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
