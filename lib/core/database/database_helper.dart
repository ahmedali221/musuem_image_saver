import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'museum_profiles.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await _createLocalGalleryDrafts(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        notes TEXT NOT NULL,
        partType TEXT NOT NULL,
        signatureType TEXT NOT NULL,
        muralWidth REAL,
        muralHeight REAL,
        imagePaths TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    await _createLocalGalleryDrafts(db);
  }

  Future<void> _createLocalGalleryDrafts(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_gallery_drafts (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id  INTEGER NOT NULL,
        landmark_id INTEGER NOT NULL,
        project_name  TEXT NOT NULL DEFAULT '',
        landmark_name TEXT NOT NULL DEFAULT '',
        name          TEXT NOT NULL,
        part_type     TEXT NOT NULL,
        signature_type TEXT NOT NULL,
        width         REAL,
        height        REAL,
        description   TEXT NOT NULL DEFAULT '',
        notes         TEXT NOT NULL DEFAULT '',
        image_paths   TEXT NOT NULL DEFAULT '',
        created_at    TEXT NOT NULL
      )
    ''');
  }
}
