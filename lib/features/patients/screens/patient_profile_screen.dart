import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/core/widgets/dismiss_background.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/core/widgets/section_title.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';
import 'package:directorio_dental/features/patients/screens/patient_form_screen.dart';
import 'package:directorio_dental/features/patients/services/local_patient_service.dart';
import 'package:directorio_dental/features/patients/widgets/info_row.dart';
import 'package:directorio_dental/features/treatments/models/treatment.dart';
import 'package:directorio_dental/features/treatments/screens/treatment_screen.dart';
import 'package:directorio_dental/features/treatments/services/local_treatment_service.dart';
import 'package:directorio_dental/features/photos/models/photo.dart';
import 'package:directorio_dental/features/photos/screens/photo_viewer_screen.dart';
import 'package:directorio_dental/features/photos/services/local_photo_service.dart';
import 'package:directorio_dental/features/photos/widgets/photo_gallery.dart';
import 'package:directorio_dental/features/treatments/widgets/treatment_card.dart';

class PatientProfileScreen extends StatefulWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final LocalPatientService _patientService = LocalPatientService();
  final LocalTreatmentService _treatmentService = LocalTreatmentService();

  // Se guarda una copia del paciente para poder actualizarla al editarlo
  late Patient _paciente;
  final LocalPhotoService _photoService = LocalPhotoService();
  List<Treatment> _tratamientos = [];
  List<Photo> _fotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _paciente = widget.patient;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final tratamientos =
        await _treatmentService.getTreatmentsByPatient(_paciente.id!);
    final fotos = await _photoService.getPhotosByPatient(_paciente.id!);

    if (!mounted) return;

    setState(() {
      _tratamientos = tratamientos;
      _fotos = fotos;
      _isLoading = false;
    });
  }

  Future<void> _editarPaciente() async {
    final editado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormScreen(patient: _paciente),
      ),
    );

    if (editado != null && editado is Patient) {
      await _patientService.updatePatient(editado);

      if (!mounted) return;

      setState(() {
        _paciente = editado;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados')),
      );
    }
  }

  // Si "tratamiento" es null se abre el formulario para uno nuevo;
  // si trae un tratamiento, se abre para editarlo.
  Future<void> _abrirTratamiento(Treatment? tratamiento) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentScreen(
          patient: _paciente,
          treatment: tratamiento,
        ),
      ),
    );

    if (resultado != null && resultado is Treatment) {
      final bool esNuevo = resultado.id == null;
      if (esNuevo) {
        await _treatmentService.insertTreatment(resultado);
      } else {
        await _treatmentService.updateTreatment(resultado);
      }
      await _cargarDatos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              esNuevo
                  ? 'Tratamiento guardado. Tócalo para agregar fotos.'
                  : 'Tratamiento guardado',
            ),
          ),
        );
      }
    } else {
      await _cargarDatos();
    }
  }

  Future<bool> _confirmarEliminar(Treatment tratamiento) async {
    final bool? respuesta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar tratamiento?'),
        content: Text(
          'Se eliminará el tratamiento de ${tratamiento.tipo}. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return respuesta ?? false;
  }

  Future<void> _eliminarTratamiento(Treatment tratamiento) async {
    // Primero se quita de la lista en pantalla (lo exige el Dismissible)
    setState(() {
      _tratamientos.remove(tratamiento);
    });

    await _photoService.deleteFilesByTreatment(tratamiento.id!);
    await _treatmentService.deleteTreatment(tratamiento.id!);
    await _cargarDatos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tratamiento de ${tratamiento.tipo} eliminado')),
    );
  }

  Future<void> _abrirFoto(Photo foto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoViewerScreen(photo: foto)),
    );
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    final Patient paciente = _paciente;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expediente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar paciente',
            onPressed: _editarPaciente,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirTratamiento(null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tratamiento'),
      ),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            // Encabezado con nombre y edad
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        paciente.nombre[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paciente.nombre,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${paciente.edad} años',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Datos generales
            const SectionTitle(icon: Icons.badge, text: 'Datos generales'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: paciente.telefono,
                    ),
                    InfoRow(
                      icon: Icons.cake,
                      label: 'Fecha de nacimiento',
                      value: paciente.fechaNacimiento,
                    ),
                  ],
                ),
              ),
            ),

            // Salud
            const SectionTitle(
              icon: Icons.health_and_safety,
              text: 'Salud del paciente',
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.warning_amber,
                      label: 'Alergias',
                      value: paciente.alergias,
                    ),
                    InfoRow(
                      icon: Icons.favorite_border,
                      label: 'Padecimientos',
                      value: paciente.padecimientos,
                    ),
                    InfoRow(
                      icon: Icons.medication,
                      label: 'Medicamentos',
                      value: paciente.medicamentos,
                    ),
                    InfoRow(
                      icon: Icons.notes,
                      label: 'Observaciones',
                      value: paciente.observaciones,
                    ),
                  ],
                ),
              ),
            ),

            // Historial de tratamientos
            SectionTitle(
              icon: Icons.history,
              text: 'Historial de tratamientos (${_tratamientos.length})',
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else if (_tratamientos.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aún no hay tratamientos registrados.'),
                ),
              )
            else
              Column(
                children: _tratamientos.map((tratamiento) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Dismissible(
                        key: ValueKey('tratamiento_${tratamiento.id}'),
                        direction: DismissDirection.startToEnd,
                        background: const DismissBackground(),
                        confirmDismiss: (direccion) =>
                            _confirmarEliminar(tratamiento),
                        onDismissed: (direccion) =>
                            _eliminarTratamiento(tratamiento),
                        child: TreatmentCard(
                          treatment: tratamiento,
                          onTap: () => _abrirTratamiento(tratamiento),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            SectionTitle(
              icon: Icons.photo_library,
              text: 'Fotografías (${_fotos.length})',
            ),
            PhotoGallery(fotos: _fotos, onTapFoto: _abrirFoto),
          ],
        ),
      ),
    );
  }
}
