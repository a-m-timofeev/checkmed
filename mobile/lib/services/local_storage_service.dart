import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication.dart';

class LocalStorageService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'drug_interaction.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Medications table
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dose TEXT,
        unit TEXT,
        frequency TEXT,
        time TEXT,
        route TEXT,
        external_ids TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    
    // Cache table for offline access
    await db.execute('''
      CREATE TABLE medication_cache (
        name TEXT PRIMARY KEY,
        rxcui TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');
    
    // User settings
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }
  
  // Medications
  Future<List<Medication>> getMedications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Medication.fromJson({
        'id': maps[i]['id'],
        'name': maps[i]['name'],
        'dose': maps[i]['dose'],
        'unit': maps[i]['unit'],
        'frequency': maps[i]['frequency'],
        'time': maps[i]['time'],
        'route': maps[i]['route'],
      });
    });
  }
  
  Future<void> saveMedication(Medication medication) async {
    final db = await database;
    await db.insert(
      'medications',
      {
        'id': medication.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'name': medication.name,
        'dose': medication.dose,
        'unit': medication.unit,
        'frequency': medication.frequency,
        'time': medication.time,
        'route': medication.route,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> deleteMedication(String id) async {
    final db = await database;
    await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> clearMedications() async {
    final db = await database;
    await db.delete('medications');
  }
  
  // User settings
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }
  
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('medications');
    await db.delete('medication_cache');
    await db.delete('user_settings');
  }
}