import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/routes.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: const AssetImage('images/perfil.png'),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 24),
              Text(
                '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 40),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.work_history_outlined),
                title: const Text('Mis aplicaciones'),
                subtitle: const Text('Ver vacantes a las que he aplicado'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/my-applications');
                },
              ),
              ListTile(
                leading: const Icon(Icons.stars_outlined),
                title: const Text('Mis experiencias'),
                subtitle: const Text('Gestionar mi historial laboral'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/experiences');
                },
              ),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Mis pagos'),
                subtitle: const Text('Historial de transacciones'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/my-payments');
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('Mis me gusta'),
                subtitle: const Text('Ofertas que me han interesado'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/liked-offers');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Datos Personales'),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.personalData);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Configuración'),
                onTap: () {},
              ),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }
}
