import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/core/widgets/dismiss_background.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';
import 'package:directorio_dental/features/patients/screens/patient_form_screen.dart';
import 'package:directorio_dental/features/patients/screens/patient_profile_screen.dart';
import 'package:directorio_dental/features/patients/services/local_patient_service.dart';
import 'package:directorio_dental/features/patients/widgets/patient_card.dart';
import 'package:directorio_dental/features/photos/services/local_photo_service.dart';
import 'package:directorio_dental/features/treatments/services/local_treatment_service.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final LocalPatientService _patientService = LocalPatientService();
  final LocalTreatmentService _treatmentService = LocalTreatmentService();
  final LocalPhotoService _photoService = LocalPhotoService();

  final List<String> _filtros = [
    'Todos',
    'En tratamiento',
    'Sin tratamiento activo',
  ];
  String _filtroSeleccionado = 'Todos';
  String _busqueda = '';

  List<Patient> _pacientes = [];
  // ids de los pacientes que tienen un tratamiento en proceso
  Set<int> _idsEnTratamiento = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final pacientes = await _patientService.getPatients();
    final enCurso = await _treatmentService.getInProgressTreatments();

    if (!mounted) return;

    setState(() {
      _pacientes = pacientes;
      _idsEnTratamiento = enCurso.map((t) => t.pacienteId).toSet();
      _isLoading = false;
    });
  }

  // Lista ya filtrada por la búsqueda y por el menú desplegable
  List<Patient> get _pacientesFiltrados {
    return _pacientes.where((paciente) {
      final bool coincideNombre =
          paciente.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
              paciente.telefono.contains(_busqueda);
      final bool enTratamiento = _idsEnTratamiento.contains(paciente.id);

      bool coincideFiltro = true;
      if (_filtroSeleccionado == 'En tratamiento') {
        coincideFiltro = enTratamiento;
      } else if (_filtroSeleccionado == 'Sin tratamiento activo') {
        coincideFiltro = !enTratamiento;
      }

      return coincideNombre && coincideFiltro;
    }).toList();
  }

  // Pregunta antes de borrar un expediente completo
  Future<bool> _confirmarEliminar(Patient paciente) async {
    final bool? respuesta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar paciente?'),
        content: Text(
          'Se eliminará el expediente de ${paciente.nombre} junto con todos '
          'sus tratamientos. Esta acción no se puede deshacer.',
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

  Future<void> _eliminarPaciente(Patient paciente) async {
    // Primero se quita de la lista en pantalla (lo exige el Dismissible)
    setState(() {
      _pacientes.remove(paciente);
    });

    await _photoService.deleteFilesByPatient(paciente.id!);
    await _patientService.deletePatient(paciente.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${paciente.nombre} fue eliminado')),
    );
  }

  Future<void> _abrirPerfil(Patient paciente) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientProfileScreen(patient: paciente),
      ),
    );
    _cargarDatos();
  }

  Future<void> _nuevoPaciente() async {
    final nuevo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientFormScreen()),
    );

    if (nuevo != null && nuevo is Patient) {
      await _patientService.insertPatient(nuevo);
      await _cargarDatos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente registrado')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Patient> pacientes = _pacientesFiltrados;

    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoPaciente,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo paciente'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ResponsiveCenter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        // Barra de búsqueda
                        TextField(
                          onChanged: (texto) {
                            setState(() {
                              _busqueda = texto;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Buscar por nombre o teléfono',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Menú desplegable de filtro
                        Row(
                          children: [
                            const Icon(
                              Icons.filter_list,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Mostrar:',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 12),
                            DropdownButton<String>(
                              value: _filtroSeleccionado,
                              items: _filtros.map((filtro) {
                                return DropdownMenuItem<String>(
                                  value: filtro,
                                  child: Text(filtro),
                                );
                              }).toList(),
                              onChanged: (nuevoValor) {
                                if (nuevoValor != null) {
                                  setState(() {
                                    _filtroSeleccionado = nuevoValor;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: pacientes.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _pacientes.isEmpty
                                    ? 'Aún no hay pacientes registrados.\nToca "Nuevo paciente" para agregar al primero.'
                                    : 'No se encontraron pacientes',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                            itemCount: pacientes.length,
                            itemBuilder: (context, index) {
                              final paciente = pacientes[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Dismissible(
                                    key: ValueKey('paciente_${paciente.id}'),
                                    direction: DismissDirection.startToEnd,
                                    background: const DismissBackground(),
                                    confirmDismiss: (direccion) =>
                                        _confirmarEliminar(paciente),
                                    onDismissed: (direccion) =>
                                        _eliminarPaciente(paciente),
                                    child: PatientCard(
                                      patient: paciente,
                                      enTratamiento: _idsEnTratamiento
                                          .contains(paciente.id),
                                      onTap: () => _abrirPerfil(paciente),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
