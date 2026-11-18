import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:directorio_dental/core/database/database_helper.dart';
import 'package:directorio_dental/features/photos/models/photo.dart';

class LocalPhotoService {
  final dbHelper = DatabaseHelper.instance;
  final ImagePicker _picker = ImagePicker();

  Future<Photo?> capturarYGuardar(int tratamientoId, ImageSource origen) async {
    final XFile? imagen = await _picker.pickImage(
      source: origen,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (imagen == null) {
      return null;
    }

    final Directory base = await getApplicationDocumentsDirectory();
    final Directory carpeta = Directory(p.join(base.path, 'fotos'));
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    final String extension =
        p.extension(imagen.path).isEmpty ? '.jpg' : p.extension(imagen.path);
    final String destino = p.join(
      carpeta.path,
      '${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await File(imagen.path).copy(destino);

    final int id = await insertPhoto(
      Photo(tratamientoId: tratamientoId, ruta: destino),
    );
    return Photo(id: id, tratamientoId: tratamientoId, ruta: destino);
  }

  Future<int> insertPhoto(Photo photo) async {
    final db = await dbHelper.database;
    return await db.insert('fotos', photo.toMap());
  }

  Future<List<Photo>> getPhotosByTreatment(int tratamientoId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'fotos',
      where: 'tratamiento_id = ?',
      whereArgs: [tratamientoId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return Photo.fromMap(maps[i]);
    });
  }

  Future<List<Photo>> getPhotosByPatient(int pacienteId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT f.* FROM fotos f
      INNER JOIN tratamientos t ON f.tratamiento_id = t.id
      WHERE t.paciente_id = ?
      ORDER BY f.id DESC
    ''', [pacienteId]);

    return List.generate(maps.length, (i) {
      return Photo.fromMap(maps[i]);
    });
  }

  Future<int> deletePhoto(Photo photo) async {
    final db = await dbHelper.database;
    await _borrarArchivo(photo.ruta);

    return await db.delete(
      'fotos',
      where: 'id = ?',
      whereArgs: [photo.id],
    );
  }

  Future<void> deleteFilesByTreatment(int tratamientoId) async {
    final fotos = await getPhotosByTreatment(tratamientoId);
    for (final foto in fotos) {
      await _borrarArchivo(foto.ruta);
    }
  }

  Future<void> deleteFilesByPatient(int pacienteId) async {
    final fotos = await getPhotosByPatient(pacienteId);
    for (final foto in fotos) {
      await _borrarArchivo(foto.ruta);
    }
  }

  Future<void> _borrarArchivo(String ruta) async {
    final File archivo = File(ruta);
    if (await archivo.exists()) {
      await archivo.delete();
    }
  }
}
