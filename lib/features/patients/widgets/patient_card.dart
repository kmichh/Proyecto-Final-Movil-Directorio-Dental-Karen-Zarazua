import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({super.key, required this.patient, required this.onTap});

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
        subtitle: Text('${patient.edad} años'),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      ),
    );
  }
}
