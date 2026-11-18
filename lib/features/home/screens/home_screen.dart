import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/core/widgets/section_title.dart';
import 'package:directorio_dental/features/auth/screens/login_screen.dart';
import 'package:directorio_dental/features/auth/services/auth_service.dart';
import 'package:directorio_dental/features/home/widgets/quick_action_card.dart';
import 'package:directorio_dental/features/home/widgets/summary_card.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';
import 'package:directorio_dental/features/patients/screens/patient_form_screen.dart';
import 'package:directorio_dental/features/patients/screens/patient_profile_screen.dart';
import 'package:directorio_dental/features/patients/screens/patients_list_screen.dart';
import 'package:directorio_dental/features/patients/services/local_patient_service.dart';
import 'package:directorio_dental/features/treatments/models/treatment.dart';
import 'package:directorio_dental/features/treatments/services/local_treatment_service.dart';
import 'package:directorio_dental/features/treatments/widgets/treatment_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalPatientService _patientService = LocalPatientService();
  final LocalTreatmentService _treatmentService = LocalTreatmentService();
  final AuthService _authService = AuthService();

  List<Patient> _pacientes = [];
  List<Treatment> _enCurso = [];
  bool _isLoading = true; // solo es true la primera vez que carga

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Lee de la base de datos lo que muestra el inicio
  Future<void> _cargarDatos() async {
    final pacientes = await _patientService.getPatients();
    final enCurso = await _treatmentService.getInProgressTreatments();

    if (!mounted) return;

    setState(() {
      _pacientes = pacientes;
      _enCurso = enCurso;
      _isLoading = false;
    });
  }

  Patient? _buscarPaciente(int id) {
    for (final paciente in _pacientes) {
      if (paciente.id == id) {
        return paciente;
      }
    }
    return null;
  }

  void _confirmarCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tendrás que volver a escribir tu usuario y contraseña.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cerrarSesion();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _irAPacientes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientsListScreen()),
    );
    // Al regresar se vuelven a leer los datos por si hubo cambios
    _cargarDatos();
  }

  // La pantalla del formulario regresa el paciente nuevo
  // y aquí se guarda en la base de datos.
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

  Future<void> _abrirPerfil(int pacienteId) async {
    final paciente = _buscarPaciente(pacienteId);
    if (paciente == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientProfileScreen(patient: paciente),
      ),
    );
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio Dental'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _confirmarCerrarSesion,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ResponsiveCenter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner de bienvenida
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hola, Doctora',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '¿Qué quieres hacer hoy?',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.sentiment_very_satisfied,
                            size: 64,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Resumen
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.people,
                            value: _pacientes.length.toString(),
                            label: 'Pacientes\nregistrados',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.medical_services,
                            value: _enCurso.length.toString(),
                            label: 'Tratamientos\nen curso',
                          ),
                        ),
                      ],
                    ),

                    // Accesos rápidos
                    const SectionTitle(
                      icon: Icons.touch_app,
                      text: 'Accesos rápidos',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionCard(
                            icon: Icons.people,
                            label: 'Ver pacientes',
                            onTap: _irAPacientes,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionCard(
                            icon: Icons.person_add,
                            label: 'Nuevo paciente',
                            onTap: _nuevoPaciente,
                          ),
                        ),
                      ],
                    ),

                    // Tratamientos en curso
                    const SectionTitle(
                      icon: Icons.pending_actions,
                      text: 'Tratamientos en curso',
                    ),
                    if (_enCurso.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No hay tratamientos en curso por ahora.',
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _enCurso.map((tratamiento) {
                          final paciente =
                              _buscarPaciente(tratamiento.pacienteId);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TreatmentCard(
                              treatment: tratamiento,
                              pacienteNombre: paciente?.nombre,
                              onTap: () => _abrirPerfil(tratamiento.pacienteId),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
