import 'package:directorio_dental/core/database/database_helper.dart';
import 'package:directorio_dental/core/storage/local_storage_service.dart';

// Login y registro LOCALES (sin internet): el usuario se guarda en la base
// de datos del dispositivo y la sesión en LocalStorageService.
class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final LocalStorageService _storage = LocalStorageService();

  // ¿Ya existe la cuenta de la dentista?
  Future<bool> hayUsuarioRegistrado() async {
    final db = await _dbHelper.database;
    final resultado = await db.query('usuarios', limit: 1);
    return resultado.isNotEmpty;
  }

  // La app es de un solo usuario: solo se puede crear la cuenta una vez.
  Future<bool> register(String usuario, String password) async {
    try {
      if (await hayUsuarioRegistrado()) {
        return false;
      }

      final db = await _dbHelper.database;
      await db.insert('usuarios', {
        'usuario': usuario.trim(),
        'password': password,
      });
      await _storage.saveSession(usuario.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String usuario, String password) async {
    try {
      final db = await _dbHelper.database;
      final resultado = await db.query(
        'usuarios',
        where: 'usuario = ? AND password = ?',
        whereArgs: [usuario.trim(), password],
      );

      if (resultado.isNotEmpty) {
        await _storage.saveSession(usuario.trim());
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteSession();
  }
}
