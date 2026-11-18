import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Base de datos local (SQLite) de toda la app.
// Es un "singleton": solo existe una y todas las pantallas usan la misma
// (mismo patrón que DatabaseHelper de fit_track_pro).
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Activa las llaves foráneas: así, al eliminar un paciente se eliminan
  // solos sus tratamientos y fotos (ON DELETE CASCADE).
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // Usuario de la app (la dentista)
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Pacientes
    await db.execute('''
      CREATE TABLE pacientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        edad INTEGER NOT NULL,
        telefono TEXT NOT NULL,
        fecha_nacimiento TEXT NOT NULL,
        alergias TEXT NOT NULL,
        padecimientos TEXT NOT NULL,
        medicamentos TEXT NOT NULL,
        observaciones TEXT NOT NULL
      )
    ''');

    // Tratamientos: cada uno pertenece a un paciente
    await db.execute('''
      CREATE TABLE tratamientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        citas_realizadas INTEGER NOT NULL,
        estado TEXT NOT NULL,
        fecha TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (paciente_id) REFERENCES pacientes (id) ON DELETE CASCADE
      )
    ''');

    // Fotos de cada tratamiento (se usará cuando se conecte la cámara).
    // Se crea desde ahora para no tener que modificar la base después.
    await db.execute('''
      CREATE TABLE fotos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tratamiento_id INTEGER NOT NULL,
        ruta TEXT NOT NULL,
        FOREIGN KEY (tratamiento_id) REFERENCES tratamientos (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE tratamientos ADD COLUMN fecha TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('directorio_dental.db');
    return _database!;
  }
}
