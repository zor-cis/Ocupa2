import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';

class PersonalDataView extends StatelessWidget {
  const PersonalDataView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Personales'),
      ),
      body: user == null
          ? const Center(child: Text('No se pudo cargar la información'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: const AssetImage('Images/perfil.png'),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _DataItem(
                    label: 'Nombre Completo',
                    value: '${user.firstName} ${user.lastName}',
                    icon: Icons.person_outline,
                  ),
                  _DataItem(
                    label: 'Correo Electrónico',
                    value: user.email,
                    icon: Icons.email_outlined,
                  ),
                  _DataItem(
                    label: 'Cédula',
                    value: user.cedula ?? 'No especificada',
                    icon: Icons.badge_outlined,
                  ),
                  _DataItem(
                    label: 'Género',
                    value: user.gender ?? 'No especificado',
                    icon: Icons.wc_outlined,
                  ),
                  _DataItem(
                    label: 'Fecha de Nacimiento',
                    value: user.birthDate != null
                        ? DateFormat('dd/MM/yyyy').format(user.birthDate!)
                        : 'No especificada',
                    icon: Icons.cake_outlined,
                  ),
                ],
              ),
            ),
    );
  }
}

class _DataItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DataItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
