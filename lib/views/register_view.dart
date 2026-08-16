import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _referralController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      password: _passwordController.text,
      referralMatricula: _referralController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      final needsProfile = auth.currentUser?.profileCompleted == false;
      Navigator.pushReplacementNamed(
        context,
        needsProfile ? AppRoutes.completeProfile : AppRoutes.home,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'No se pudo completar el registro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Necesitas la matrícula de un estudiante del ITLA que te refiera.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _emailController,
                  label: 'Correo',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
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
                  controller: _referralController,
                  label: 'Matrícula de quien te refiere',
                  validator: Validators.matricula,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscureText: _obscure,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmController,
                  label: 'Confirmar contraseña',
                  obscureText: _obscure,
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Registrarme',
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