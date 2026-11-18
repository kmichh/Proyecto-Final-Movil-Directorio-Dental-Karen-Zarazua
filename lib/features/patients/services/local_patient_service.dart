import 'package:directorio_dental/core/database/database_helper.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';

// Operaciones CRUD de pacientes en la base de datos local.
class LocalPatientService {
  final dbHelper = DatabaseHelper.instance;

  // Crear
  Future<int> insertPatient(Patient patient) async {
    final db = await dbHelper.database;
    return await db.insert('pacientes', patient.toMap());
  }

  // Leer (ordenados por nombre)
  Future<List<Patient>> getPatients() async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'pacientes',
      orderBy: 'nombre COLLATE NOCASE ASC',
    );

    return List.generate(maps.length, (i) {
      return Patient.fromMap(maps[i]);
    });
  }

  // Modificar
  Future<int> updatePatient(Patient patient) async {
    final db = await dbHelper.database;

    return await db.update(
      'pacientes',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  // Eliminar (sus tratamientos y fotos se eliminan solos)
  Future<int> deletePatient(int id) async {
    final db = await dbHelper.database;

    return await db.delete(
      'pacientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
