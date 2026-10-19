import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/core/widgets/section_title.dart';
import 'package:directorio_dental/features/auth/screens/login_screen.dart';
import 'package:directorio_dental/features/home/widgets/quick_action_card.dart';
import 'package:directorio_dental/features/home/widgets/summary_card.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';
import 'package:directorio_dental/features/patients/screens/patient_form_screen.dart';
import 'package:directorio_dental/features/patients/screens/patients_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Al regresar de otra pantalla se hace setState para que
  // el contador de pacientes se actualice.
  void _irAPacientes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientsListScreen()),
    ).then((_) {
      setState(() {});
    });
  }

  void _nuevoPaciente() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientFormScreen()),
    ).then((_) {
      setState(() {});
    });
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
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
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
              SummaryCard(
                icon: Icons.people,
                value: listaPacientes.length.toString(),
                label: 'Pacientes registrados',
              ),

              // Accesos rápidos
              const SectionTitle(icon: Icons.touch_app, text: 'Accesos rápidos'),
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
            ],
          ),
        ),
      ),
    );
  }
}
