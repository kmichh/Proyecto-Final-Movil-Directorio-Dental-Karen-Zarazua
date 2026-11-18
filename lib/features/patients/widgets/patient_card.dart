import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final bool enTratamiento; // ¿tiene un tratamiento en proceso?
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patient,
    required this.enTratamiento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.primary,
          child: Text(
            patient.nombre[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patient.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.telefono.isEmpty
                  ? '${patient.edad} años'
                  : '${patient.edad} años · ${patient.telefono}',
            ),
            if (enTratamiento)
              const Row(
                children: [
                  Icon(Icons.medical_services,
                      size: 14, color: AppColors.warning),
                  SizedBox(width: 4),
                  Text(
                    'Tratamiento en curso',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      ),
    );
  }
}
