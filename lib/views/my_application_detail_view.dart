import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/application.dart';

class MyApplicationDetailView extends StatelessWidget {
  const MyApplicationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final application = ModalRoute.of(context)?.settings.arguments as Application?;

    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Aplicación')),
        body: const Center(child: Text('No se encontró la información de la aplicación')),
      );
    }

    final offer = application.offer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Aplicación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                offer.photo,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 60),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Text(
              offer.jobTypeName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            _InfoRow(
              icon: Icons.work_outline,
              label: 'Contrato',
              value: offer.contractType,
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Ubicación',
              value: offer.address,
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.payments_outlined,
              label: 'Pago',
              value: '${offer.payment.amount} ${offer.payment.currency} / ${offer.payment.period}',
            ),

            const SizedBox(height: 24),

            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              offer.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),
            if (application.comment.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Tu comentario',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(application.comment),
              ),
            ],

            const SizedBox(height: 24),

            // Estado de la aplicación (movido aquí abajo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(application.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(application.status)),
              ),
              child: Column(
                children: [
                  Text(
                    'ESTADO: ${application.status.toUpperCase()}',
                    style: TextStyle(
                      color: _getStatusColor(application.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aplicaste el: ${DateFormat('dd/MM/yyyy').format(application.createdAt)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'winner':
        return Colors.green;
      case 'finalist':
        return Colors.blue;
      case 'discarded':
        return Colors.red;
      case 'applied':
      default:
        return Colors.orange;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
