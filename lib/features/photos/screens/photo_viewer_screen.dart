import 'dart:io';
import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/features/photos/models/photo.dart';
import 'package:directorio_dental/features/photos/services/local_photo_service.dart';

class PhotoViewerScreen extends StatelessWidget {
  final Photo photo;

  const PhotoViewerScreen({super.key, required this.photo});

  Future<void> _eliminar(BuildContext context) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar fotografía?'),
        content: const Text('Esta acción no se puede deshacer.'),
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

    if (confirmar != true) {
      return;
    }

    await LocalPhotoService().deletePhoto(photo);

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Fotografía'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar fotografía',
            onPressed: () => _eliminar(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(photo.ruta),
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              color: Colors.white54,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }
}
