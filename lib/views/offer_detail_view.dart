import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/offer_provider.dart';
import '../widgets/custom_button.dart';

class OfferDetailView extends StatefulWidget {
  const OfferDetailView({super.key});

  @override
  State<OfferDetailView> createState() => _OfferDetailViewState();
}

class _OfferDetailViewState extends State<OfferDetailView> {
  String? _offerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_offerId != null) return;

    final id = ModalRoute.of(context)?.settings.arguments as String?;

    if (id == null) return;

    _offerId = id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferProvider>().loadOfferDetail(id);
    });
  }

  Future<void> _apply() async {
    if (_offerId == null) return;

    final provider = context.read<OfferProvider>();

    final success = await provider.applyToOffer(_offerId!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Aplicaste correctamente a la oferta!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'No se pudo aplicar a la oferta',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OfferProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de oferta'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(OfferProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final offer = provider.selectedOffer;

    if (offer == null) {
      return const Center(
        child: Text('No se encontró la oferta'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la oferta
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
                    child: Icon(
                      Icons.image_not_supported,
                      size: 60,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Tipo de trabajo
          Text(
            offer.jobTypeName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 12),

          // Tipo de contrato
          _InfoRow(
            icon: Icons.work_outline,
            label: 'Contrato',
            value: offer.contractType,
          ),

          const SizedBox(height: 12),

          // Ubicación
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Ubicación',
            value: offer.address,
          ),

          const SizedBox(height: 12),

          // Pago
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Pago',
            value:
                '${offer.payment.amount} ${offer.payment.currency} / ${offer.payment.period}',
          ),

          const SizedBox(height: 24),

          // Descripción
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

          // Fecha límite
          if (offer.deadline != null) ...[
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha límite',
              value: DateFormat('dd/MM/yyyy').format(offer.deadline!),
            ),
            const SizedBox(height: 24),
          ],

          // Botón aplicar
          CustomButton(
            label: 'Aplicar',
            isLoading: provider.isApplying,
            onPressed: provider.isApplying ? null : _apply,
          ),
        ],
      ),
    );
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
        Icon(
          icon,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}