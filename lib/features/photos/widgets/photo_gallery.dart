import 'dart:io';
import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/features/photos/models/photo.dart';

class PhotoGallery extends StatelessWidget {
  final List<Photo> fotos;
  final void Function(Photo foto) onTapFoto;
  final VoidCallback? onAgregar;

  const PhotoGallery({
    super.key,
    required this.fotos,
    required this.onTapFoto,
    this.onAgregar,
  });

  Widget _botonAgregar() {
    return InkWell(
      onTap: onAgregar,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 34, color: AppColors.primaryDark),
            SizedBox(height: 4),
            Text(
              'Agregar foto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniatura(Photo foto) {
    return InkWell(
      onTap: () => onTapFoto(foto),
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(foto.ruta),
          fit: BoxFit.cover,
          cacheWidth: 300,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: Icon(Icons.broken_image, color: Colors.grey.shade500),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool puedeAgregar = onAgregar != null;
    final int total = fotos.length + (puedeAgregar ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fotos.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: puedeAgregar ? 10 : 0),
            child: Text(
              puedeAgregar
                  ? 'Aún no hay fotografías.'
                  : 'Aún no hay fotografías. Se agregan desde cada tratamiento.',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 15,
              ),
            ),
          ),
        if (total > 0)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: total,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 130,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (puedeAgregar && index == 0) {
                return _botonAgregar();
              }
              return _miniatura(fotos[puedeAgregar ? index - 1 : index]);
            },
          ),
      ],
    );
  }
}
