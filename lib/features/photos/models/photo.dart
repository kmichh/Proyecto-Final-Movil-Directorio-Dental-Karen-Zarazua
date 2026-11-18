class Photo {
  final int? id;
  final int tratamientoId;
  final String ruta;

  Photo({this.id, required this.tratamientoId, required this.ruta});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tratamiento_id': tratamientoId,
      'ruta': ruta,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      tratamientoId: map['tratamiento_id'],
      ruta: map['ruta'],
    );
  }
}
