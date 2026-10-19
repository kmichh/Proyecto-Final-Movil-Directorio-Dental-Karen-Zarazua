import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/core/widgets/dismiss_background.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';
import 'package:directorio_dental/features/patients/screens/patient_form_screen.dart';
import 'package:directorio_dental/features/patients/screens/patient_profile_screen.dart';
import 'package:directorio_dental/features/patients/widgets/patient_card.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  void _eliminarPaciente(Patient paciente) {
    setState(() {
      listaPacientes.remove(paciente);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${paciente.nombre} fue eliminado')),
    );
  }

  void _abrirPerfil(Patient paciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientProfileScreen(patient: paciente),
      ),
    );
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
      appBar: AppBar(title: const Text('Pacientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoPaciente,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo paciente'),
      ),
      body: ResponsiveCenter(
        child: listaPacientes.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Aún no hay pacientes registrados.\nToca "Nuevo paciente" para agregar al primero.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textLight),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: listaPacientes.length,
                itemBuilder: (context, index) {
                  final paciente = listaPacientes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Dismissible(
                        key: ValueKey(paciente),
                        direction: DismissDirection.startToEnd,
                        background: const DismissBackground(),
                        onDismissed: (direccion) => _eliminarPaciente(paciente),
                        child: PatientCard(
                          patient: paciente,
                          onTap: () => _abrirPerfil(paciente),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
