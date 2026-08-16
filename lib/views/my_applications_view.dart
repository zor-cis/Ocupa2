import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/offer_provider.dart';
import '../utils/routes.dart';

class MyApplicationsView extends StatefulWidget {
  const MyApplicationsView({super.key});

  @override
  State<MyApplicationsView> createState() => _MyApplicationsViewState();
}

class _MyApplicationsViewState extends State<MyApplicationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferProvider>().loadMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Aplicaciones'),
      ),
      body: Consumer<OfferProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadMyApplications(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.myApplications.isEmpty) {
            return const Center(
              child: Text('Aún no has aplicado a ninguna vacante.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.myApplications.length,
            itemBuilder: (context, index) {
              final application = provider.myApplications[index];
              final offer = application.offer;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    offer.jobTypeName.isNotEmpty ? offer.jobTypeName : 'Vacante sin título',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Estado: ${application.status.toUpperCase()}'),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(application.createdAt)}',
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.applicationDetail,
                      arguments: application,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
