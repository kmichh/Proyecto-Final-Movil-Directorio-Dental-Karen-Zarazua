class Patient {
  final int? id; // lo asigna la base de datos al guardar
  final String nombre;
  final int edad;
  final String telefono;
  final String fechaNacimiento;
  final String alergias;
  final String padecimientos;
  final String medicamentos;
  final String observaciones;

  Patient({
    this.id,
    required this.nombre,
    required this.edad,
    required this.telefono,
    required this.fechaNacimiento,
    required this.alergias,
    required this.padecimientos,
    required this.medicamentos,
    required this.observaciones,
  });

  // Convierte el paciente a un Map para guardarlo en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'edad': edad,
      'telefono': telefono,
      'fecha_nacimiento': fechaNacimiento,
      'alergias': alergias,
      'padecimientos': padecimientos,
      'medicamentos': medicamentos,
      'observaciones': observaciones,
    };
  }

  // Convierte un registro de SQLite en un paciente
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      nombre: map['nombre'],
      edad: map['edad'],
      telefono: map['telefono'],
      fechaNacimiento: map['fecha_nacimiento'],
      alergias: map['alergias'],
      padecimientos: map['padecimientos'],
      medicamentos: map['medicamentos'],
      observaciones: map['observaciones'],
    );
  }
}
