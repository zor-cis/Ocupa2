import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_transaction.dart';

class PaymentDetailView extends StatelessWidget {
  const PaymentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final payment = ModalRoute.of(context)?.settings.arguments as PaymentTransaction?;

    if (payment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Pago')),
        body: const Center(child: Text('No se encontró la información del pago')),
      );
    }

    final isApproved = payment.status.toLowerCase() == 'approved' ||
        payment.status.toLowerCase() == 'success' ||
        payment.status.toLowerCase() == 'paid';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Pago'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isApproved ? Colors.green : Colors.red).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isApproved ? Icons.check_circle : Icons.cancel,
                      color: isApproved ? Colors.green : Colors.red,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${payment.amount} ${payment.currency}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isApproved ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      payment.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 24),
            _DetailItem(
              label: 'Concepto',
              value: payment.type ?? 'Pago de oferta',
              icon: Icons.description_outlined,
            ),
            _DetailItem(
              label: 'Fecha y Hora',
              value: DateFormat('dd/MM/yyyy HH:mm:ss').format(payment.createdAt),
              icon: Icons.calendar_today_outlined,
            ),
            _DetailItem(
              label: 'ID de Transacción',
              value: payment.id,
              icon: Icons.tag,
            ),
            if (payment.cardholder != null)
              _DetailItem(
                label: 'Titular de Tarjeta',
                value: payment.cardholder!,
                icon: Icons.person_outline,
              ),
            if (payment.cardLast4 != null)
              _DetailItem(
                label: 'Tarjeta (Últimos 4 dígitos)',
                value: '**** **** **** ${payment.cardLast4!}',
                icon: Icons.credit_card_outlined,
              ),
            if (!isApproved && payment.declineReason != null)
              _DetailItem(
                label: 'Motivo de Rechazo',
                value: payment.declineReason!,
                icon: Icons.warning_amber_rounded,
              ),
            _DetailItem(
              label: 'Moneda',
              value: payment.currency,
              icon: Icons.monetization_on_outlined,
            ),
            const SizedBox(height: 40),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al historial'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
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
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
