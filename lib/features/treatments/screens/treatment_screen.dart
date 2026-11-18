import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/core/widgets/section_title.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';
import 'package:directorio_dental/features/treatments/models/treatment.dart';
import 'package:directorio_dental/core/utils/fecha_utils.dart';
import 'package:directorio_dental/features/photos/models/photo.dart';
import 'package:directorio_dental/features/photos/screens/photo_viewer_screen.dart';
import 'package:directorio_dental/features/photos/services/local_photo_service.dart';
import 'package:directorio_dental/features/photos/widgets/photo_gallery.dart';

// Sirve para dos cosas:
// - Registrar un tratamiento nuevo (treatment == null)
// - Ver / editar un tratamiento que ya existe
// Igual que el formulario de paciente, REGRESA el tratamiento con
// Navigator.pop y la pantalla que la abrió lo guarda en la base de datos.
class TreatmentScreen extends StatefulWidget {
  final Patient patient;
  final Treatment? treatment;

  const TreatmentScreen({super.key, required this.patient, this.treatment});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  late String _tipo;
  late String _estado;
  late int _citas;
  late TextEditingController _descripcionController;
  final LocalPhotoService _photoService = LocalPhotoService();
  List<Photo> _fotos = [];

  bool get _esEdicion => widget.treatment != null;

  @override
  void initState() {
    super.initState();
    final Treatment? existente = widget.treatment;
    _tipo = existente?.tipo ?? tiposTratamiento.first;
    _estado = existente?.estado ?? estadoEnProceso;
    _citas = existente?.citasRealizadas ?? 1;
    _descripcionController =
        TextEditingController(text: existente?.descripcion ?? '');
    if (existente != null) {
      _cargarFotos();
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardar() {
    final tratamiento = Treatment(
      id: widget.treatment?.id, // null si es nuevo
      pacienteId: widget.patient.id!,
      tipo: _tipo,
      descripcion: _descripcionController.text.trim(),
      citasRealizadas: _citas,
      estado: _estado,
      fecha: widget.treatment?.fecha ?? fechaHoy(),
    );

    Navigator.pop(context, tratamiento);
  }

  Future<void> _cargarFotos() async {
    final fotos =
        await _photoService.getPhotosByTreatment(widget.treatment!.id!);

    if (!mounted) return;

    setState(() {
      _fotos = fotos;
    });
  }

  void _elegirOrigen() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto con la cámara'),
              onTap: () {
                Navigator.pop(context);
                _agregarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                _agregarFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _agregarFoto(ImageSource origen) async {
    try {
      final foto = await _photoService.capturarYGuardar(
        widget.treatment!.id!,
        origen,
      );
      if (foto != null) {
        await _cargarFotos();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la fotografía'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _abrirFoto(Photo foto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoViewerScreen(photo: foto)),
    );
    _cargarFotos();
  }

  // Caja blanca con borde para que los menús desplegables
  // se vean igual que los campos de texto.
  Widget _cajaDropdown({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar tratamiento' : 'Nuevo tratamiento'),
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Paciente al que pertenece
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primary),
                  title: Text(widget.patient.nombre),
                  subtitle: const Text('Paciente'),
                ),
              ),

              // Tipo de tratamiento
              const SectionTitle(
                icon: Icons.medical_services,
                text: 'Tipo de tratamiento',
              ),
              _cajaDropdown(
                child: DropdownButton<String>(
                  value: _tipo,
                  isExpanded: true,
                  items: tiposTratamiento.map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (nuevoValor) {
                    if (nuevoValor != null) {
                      setState(() {
                        _tipo = nuevoValor;
                      });
                    }
                  },
                ),
              ),

              // Descripción
              const SectionTitle(icon: Icons.notes, text: 'Descripción y avance'),
              TextField(
                controller: _descripcionController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Escribe aquí qué se hizo y cómo va el tratamiento',
                ),
              ),

              // Citas
              const SectionTitle(
                icon: Icons.event_available,
                text: 'Citas realizadas',
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 36,
                        color: AppColors.primary,
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _citas > 0
                            ? () {
                                setState(() {
                                  _citas--;
                                });
                              }
                            : null,
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          _citas.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 36,
                        color: AppColors.primary,
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            _citas++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Estado
              const SectionTitle(icon: Icons.flag, text: 'Estado'),
              _cajaDropdown(
                child: DropdownButton<String>(
                  value: _estado,
                  isExpanded: true,
                  items: estadosTratamiento.map((estado) {
                    return DropdownMenuItem<String>(
                      value: estado,
                      child: Text(estado),
                    );
                  }).toList(),
                  onChanged: (nuevoValor) {
                    if (nuevoValor != null) {
                      setState(() {
                        _estado = nuevoValor;
                      });
                    }
                  },
                ),
              ),

              const SectionTitle(
                icon: Icons.photo_library,
                text: 'Fotografías del tratamiento',
              ),
              if (_esEdicion)
                PhotoGallery(
                  fotos: _fotos,
                  onTapFoto: _abrirFoto,
                  onAgregar: _elegirOrigen,
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Guarda el tratamiento para poder agregar fotografías.',
                    ),
                  ),
                ),

              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar tratamiento'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
