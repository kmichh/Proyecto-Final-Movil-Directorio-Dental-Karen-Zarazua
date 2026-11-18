import 'package:flutter/material.dart';
import 'package:directorio_dental/core/widgets/responsive_center.dart';
import 'package:directorio_dental/core/widgets/section_title.dart';
import 'package:directorio_dental/features/patients/models/patient.dart';

// Sirve para dos cosas:
// - Registrar un paciente nuevo (patient == null)
// - Editar un paciente que ya existe
// No guarda en la base de datos: REGRESA el paciente a la pantalla que la
// abrió (Navigator.pop con resultado) y esa pantalla lo guarda.
class PatientFormScreen extends StatefulWidget {
  final Patient? patient;

  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  late TextEditingController _telefonoController;
  late TextEditingController _fechaController;
  late TextEditingController _alergiasController;
  late TextEditingController _padecimientosController;
  late TextEditingController _medicamentosController;
  late TextEditingController _observacionesController;

  bool get _esEdicion => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final Patient? existente = widget.patient;
    _nombreController = TextEditingController(text: existente?.nombre ?? '');
    _edadController = TextEditingController(
      text: existente == null ? '' : existente.edad.toString(),
    );
    _telefonoController =
        TextEditingController(text: existente?.telefono ?? '');
    _fechaController =
        TextEditingController(text: existente?.fechaNacimiento ?? '');
    _alergiasController =
        TextEditingController(text: existente?.alergias ?? '');
    _padecimientosController =
        TextEditingController(text: existente?.padecimientos ?? '');
    _medicamentosController =
        TextEditingController(text: existente?.medicamentos ?? '');
    _observacionesController =
        TextEditingController(text: existente?.observaciones ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    _alergiasController.dispose();
    _padecimientosController.dispose();
    _medicamentosController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _guardar() {
    // Revisa todos los validator del formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final paciente = Patient(
      id: widget.patient?.id, // null si es nuevo
      nombre: _nombreController.text.trim(),
      edad: int.parse(_edadController.text.trim()),
      telefono: _telefonoController.text.trim(),
      fechaNacimiento: _fechaController.text.trim(),
      alergias: _alergiasController.text.trim(),
      padecimientos: _padecimientosController.text.trim(),
      medicamentos: _medicamentosController.text.trim(),
      observaciones: _observacionesController.text.trim(),
    );

    // Regresa el paciente a la pantalla anterior
    Navigator.pop(context, paciente);
  }

  // Un campo de texto con su ícono, para no repetir tanto código
  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    TextInputType teclado = TextInputType.text,
    int lineas = 1,
    TextCapitalization mayusculas = TextCapitalization.sentences,
    String? Function(String?)? validador,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        maxLines: lineas,
        textCapitalization: mayusculas,
        validator: validador,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar paciente' : 'Nuevo paciente'),
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle(icon: Icons.badge, text: 'Datos generales'),
                _campo(
                  controller: _nombreController,
                  etiqueta: 'Nombre completo *',
                  icono: Icons.person,
                  mayusculas: TextCapitalization.words,
                  validador: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe el nombre del paciente';
                    }
                    if (value.trim().length < 3) {
                      return 'El nombre es muy corto';
                    }
                    return null;
                  },
                ),
                _campo(
                  controller: _edadController,
                  etiqueta: 'Edad *',
                  icono: Icons.numbers,
                  teclado: TextInputType.number,
                  validador: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe la edad';
                    }
                    final int? edad = int.tryParse(value.trim());
                    if (edad == null) {
                      return 'Solo se permiten números';
                    }
                    if (edad < 0 || edad > 120) {
                      return 'Escribe una edad válida';
                    }
                    return null;
                  },
                ),
                _campo(
                  controller: _telefonoController,
                  etiqueta: 'Teléfono',
                  icono: Icons.phone,
                  teclado: TextInputType.phone,
                  validador: (value) {
                    // Es opcional, pero si lo escribe debe estar completo
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    final String soloNumeros =
                        value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (soloNumeros.length < 10) {
                      return 'Escribe los 10 dígitos del teléfono';
                    }
                    return null;
                  },
                ),
                _campo(
                  controller: _fechaController,
                  etiqueta: 'Fecha de nacimiento (DD/MM/AAAA)',
                  icono: Icons.cake,
                  teclado: TextInputType.datetime,
                ),
                const SectionTitle(
                  icon: Icons.health_and_safety,
                  text: 'Salud del paciente',
                ),
                _campo(
                  controller: _alergiasController,
                  etiqueta: 'Alergias',
                  icono: Icons.warning_amber,
                ),
                _campo(
                  controller: _padecimientosController,
                  etiqueta: 'Padecimientos',
                  icono: Icons.favorite_border,
                ),
                _campo(
                  controller: _medicamentosController,
                  etiqueta: 'Medicamentos',
                  icono: Icons.medication,
                ),
                _campo(
                  controller: _observacionesController,
                  etiqueta: 'Observaciones',
                  icono: Icons.notes,
                  lineas: 3,
                ),
                const SizedBox(height: 8),
                const Text(
                  '* Campos obligatorios',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _esEdicion ? 'Guardar cambios' : 'Registrar paciente',
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
