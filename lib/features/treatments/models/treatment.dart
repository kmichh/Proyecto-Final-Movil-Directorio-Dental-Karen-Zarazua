// Estados posibles de un tratamiento
const String estadoEnProceso = 'En proceso';
const String estadoFinalizado = 'Finalizado';
const List<String> estadosTratamiento = [estadoEnProceso, estadoFinalizado];

// Tipos de tratamiento que aparecen en el menú desplegable
const List<String> tiposTratamiento = [
  'Limpieza',
  'Ortodoncia',
  'Extracción',
  'Endodoncia',
  'Resina',
  'Blanqueamiento',
  'Prótesis',
  'Otro',
];

class Treatment {
  final int? id; // lo asigna la base de datos al guardar
  final int pacienteId; // a qué paciente pertenece
  final String tipo;
  final String descripcion;
  final int citasRealizadas;
  final String estado;
  final String fecha;

  Treatment({
    this.id,
    required this.pacienteId,
    required this.tipo,
    required this.descripcion,
    required this.citasRealizadas,
    required this.estado,
    this.fecha = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paciente_id': pacienteId,
      'tipo': tipo,
      'descripcion': descripcion,
      'citas_realizadas': citasRealizadas,
      'estado': estado,
      'fecha': fecha,
    };
  }

  factory Treatment.fromMap(Map<String, dynamic> map) {
    return Treatment(
      id: map['id'],
      pacienteId: map['paciente_id'],
      tipo: map['tipo'],
      descripcion: map['descripcion'],
      citasRealizadas: map['citas_realizadas'],
      estado: map['estado'],
      fecha: map['fecha'] ?? '',
    );
  }
}
