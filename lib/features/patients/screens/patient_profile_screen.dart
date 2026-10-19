import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/core/widgets/section_title.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';
import 'package:directorio_dental/features/patients/widgets/info_row.dart';
import 'package:directorio_dental/features/treatments/screens/treatment_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  // Si un dato opcional quedó vacío, se muestra "No registrado"
  String _valor(String texto) {
    return texto.isEmpty ? 'No registrado' : texto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expediente')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TreatmentScreen(patient: patient),
            ),
          );
        },
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
                        patient.nombre[0].toUpperCase(),
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
                            patient.nombre,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${patient.edad} años',
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

            // Datos
            const SectionTitle(icon: Icons.badge, text: 'Datos del paciente'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: _valor(patient.telefono),
                    ),
                    InfoRow(
                      icon: Icons.warning_amber,
                      label: 'Alergias',
                      value: _valor(patient.alergias),
                    ),
                  ],
                ),
              ),
            ),

            // Historial (todavía sin funcionalidad)
            const SectionTitle(
              icon: Icons.history,
              text: 'Historial de tratamientos',
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aún no hay tratamientos registrados.'),
              ),
            ),

            // Fotografías (todavía sin funcionalidad)
            const SectionTitle(icon: Icons.photo_library, text: 'Fotografías'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Agregar fotografía'),
                subtitle: const Text('Próximamente'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: tomar foto con la cámara'),
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
