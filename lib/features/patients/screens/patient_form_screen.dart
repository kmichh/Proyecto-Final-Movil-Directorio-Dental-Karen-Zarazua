import 'package:flutter/material.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';

class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _alergiasController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    _alergiasController.dispose();
    super.dispose();
  }

  void _guardar() {
    final String nombre = _nombreController.text.trim();
    final int? edad = int.tryParse(_edadController.text.trim());

    // El nombre y la edad son obligatorios
    if (nombre.isEmpty || edad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre y la edad del paciente')),
      );
      return;
    }

    listaPacientes.add(
      Patient(
        nombre: nombre,
        edad: edad,
        telefono: _telefonoController.text.trim(),
        alergias: _alergiasController.text.trim(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paciente registrado')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo paciente')),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Edad *',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _alergiasController,
                decoration: const InputDecoration(
                  labelText: 'Alergias',
                  prefixIcon: Icon(Icons.warning_amber),
                ),
              ),
              const SizedBox(height: 8),
              const Text('* Campos obligatorios', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Registrar paciente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
