class Patient {
  final String nombre;
  final int edad;
  final String telefono;
  final String alergias;

  Patient({
    required this.nombre,
    required this.edad,
    required this.telefono,
    required this.alergias,
  });
}

// Lista temporal de pacientes. Vive en la memoria de la app,
// así que se borra al cerrarla. Más adelante se cambiará por una base de datos.
List<Patient> listaPacientes = [];
