String fechaHoy() {
  final DateTime ahora = DateTime.now();
  final String dia = ahora.day.toString().padLeft(2, '0');
  final String mes = ahora.month.toString().padLeft(2, '0');
  return '$dia/$mes/${ahora.year}';
}
