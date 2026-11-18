import 'package:shared_preferences/shared_preferences.dart';

// Guarda en el dispositivo quién tiene la sesión iniciada,
// para no pedir usuario y contraseña cada vez que se abre la app.
class LocalStorageService {
  static const String _sessionKey = "sesion_usuario";

  Future<void> saveSession(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, usuario);
  }

  Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<void> deleteSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
