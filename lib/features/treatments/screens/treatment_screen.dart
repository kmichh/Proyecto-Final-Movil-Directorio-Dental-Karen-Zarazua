import 'package:flutter/material.dart';
import 'package:directorio_dental/core/theme/app_colors.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/core/widgets/section_title.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';

class TreatmentScreen extends StatefulWidget {
  final Patient patient;

  const TreatmentScreen({super.key, required this.patient});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  final List<String> _tipos = [
    'Limpieza',
    'Ortodoncia',
    'Extracción',
    'Endodoncia',
    'Resina',
    'Blanqueamiento',
    'Otro',
  ];
  String _tipoSeleccionado = 'Limpieza';
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardar() {
    // Todavía no se guarda en el expediente. Por ahora solo regresa.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: el tratamiento se guardará en el expediente'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo tratamiento')),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Paciente al que pertenece
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primary),
                  title: Text(widget.patient.nombre),
                  subtitle: const Text('Paciente'),
                ),
              ),

              // Tipo de tratamiento
              const SectionTitle(
                icon: Icons.medical_services,
                text: 'Tipo de tratamiento',
              ),
              DropdownButton<String>(
                value: _tipoSeleccionado,
                isExpanded: true,
                items: _tipos.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (nuevoValor) {
                  if (nuevoValor != null) {
                    setState(() {
                      _tipoSeleccionado = nuevoValor;
                    });
                  }
                },
              ),

              // Descripción
              const SectionTitle(icon: Icons.notes, text: 'Descripción y avance'),
              TextField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Escribe aquí qué se hizo y cómo va el tratamiento',
                ),
              ),

              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar tratamiento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
