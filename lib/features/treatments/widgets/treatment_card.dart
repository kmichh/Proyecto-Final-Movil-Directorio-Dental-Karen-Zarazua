import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/features/treatments/models/treatment.dart';

class TreatmentCard extends StatelessWidget {
  final Treatment treatment;
  final String? pacienteNombre; // opcional: se muestra en el inicio
  final VoidCallback onTap;

  const TreatmentCard({
    super.key,
    required this.treatment,
    required this.onTap,
    this.pacienteNombre,
  });

  // Cada tipo de tratamiento tiene su propio ícono
  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'Limpieza':
        return Icons.cleaning_services;
      case 'Ortodoncia':
        return Icons.straighten;
      case 'Extracción':
        return Icons.remove_circle_outline;
      case 'Endodoncia':
        return Icons.healing;
      case 'Resina':
        return Icons.build;
      case 'Blanqueamiento':
        return Icons.auto_awesome;
      case 'Prótesis':
        return Icons.sentiment_satisfied_alt;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enProceso = treatment.estado == estadoEnProceso;
    final Color colorEstado = enProceso ? AppColors.warning : AppColors.success;
    final Color fondoEstado =
        enProceso ? AppColors.warningBg : AppColors.successBg;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.accent,
          child: Icon(
            _iconoPorTipo(treatment.tipo),
            color: AppColors.primaryDark,
          ),
        ),
        title: Text(
          treatment.tipo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pacienteNombre != null)
              Text(
                pacienteNombre!,
                style: const TextStyle(color: AppColors.textDark),
              ),
            Text(
              treatment.fecha.isEmpty
                  ? 'Citas realizadas: ${treatment.citasRealizadas}'
                  : '${treatment.fecha} · Citas: ${treatment.citasRealizadas}',
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: fondoEstado,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            treatment.estado,
            style: TextStyle(
              color: colorEstado,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
