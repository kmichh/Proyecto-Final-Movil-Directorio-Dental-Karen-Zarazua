import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';

// Fondo rojo que aparece al deslizar a la derecha un elemento (Dismissible).
class DismissBackground extends StatelessWidget {
  const DismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.danger,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 30),
          SizedBox(width: 8),
          Text(
            'Eliminar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
