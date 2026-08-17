import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fechaController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;

  final _generos = const {
    'masculino': 'Masculino',
    'femenino': 'Femenino',
    'otro': 'Otro',
  };

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _cedulaController.text = user.cedula ?? '';
      _gender = user.gender;
      _birthDate = user.birthDate;
      if (user.birthDate != null) {
        _fechaController.text = DateFormat('dd/MM/yyyy').format(user.birthDate!);
      }
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona tu género')));
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona tu fecha de nacimiento')));
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.completeProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      cedula: _cedulaController.text.trim(),
      gender: _gender!,
      birthDate: _birthDate!,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'No se pudo actualizar tu perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: _firstNameController,
                  label: 'Nombre',
                  validator: (v) => Validators.notEmpty(v, field: 'El nombre'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _lastNameController,
                  label: 'Apellido',
                  validator: (v) => Validators.notEmpty(v, field: 'El apellido'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _cedulaController,
                  label: 'Cédula',
                  keyboardType: TextInputType.number,
                  validator: Validators.cedula,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(labelText: 'Género'),
                  items: _generos.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _fechaController,
                  label: 'Fecha de nacimiento',
                  readOnly: true,
                  onTap: _pickDate,
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (_) => _birthDate == null ? 'Selecciona una fecha' : null,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Guardar cambios',
                  isLoading: auth.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}