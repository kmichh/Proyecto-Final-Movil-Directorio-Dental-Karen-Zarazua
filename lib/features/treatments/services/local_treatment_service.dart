import 'package:directorio_dental/core/database/database_helper.dart';
import 'package:directorio_dental/features/treatments/models/treatment.dart';

// Operaciones CRUD de tratamientos en la base de datos local.
class LocalTreatmentService {
  final dbHelper = DatabaseHelper.instance;

  // Crear
  Future<int> insertTreatment(Treatment treatment) async {
    final db = await dbHelper.database;
    return await db.insert('tratamientos', treatment.toMap());
  }

  // Leer los tratamientos de UN paciente (el más reciente primero)
  Future<List<Treatment>> getTreatmentsByPatient(int pacienteId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tratamientos',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return Treatment.fromMap(maps[i]);
    });
  }

  // Leer todos los tratamientos que siguen en proceso (para el inicio)
  Future<List<Treatment>> getInProgressTreatments() async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tratamientos',
      where: 'estado = ?',
      whereArgs: [estadoEnProceso],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return Treatment.fromMap(maps[i]);
    });
  }

  // Modificar
  Future<int> updateTreatment(Treatment treatment) async {
    final db = await dbHelper.database;

    return await db.update(
      'tratamientos',
      treatment.toMap(),
      where: 'id = ?',
      whereArgs: [treatment.id],
    );
  }

  // Eliminar
  Future<int> deleteTreatment(int id) async {
    final db = await dbHelper.database;

    return await db.delete(
      'tratamientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
