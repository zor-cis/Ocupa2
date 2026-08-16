import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/oferta_model.dart';
import '../providers/ofertas_provider.dart';

class MisPagosView extends StatefulWidget {
  const MisPagosView({super.key});

  @override
  State<MisPagosView> createState() => _MisPagosViewState();
}

class _MisPagosViewState extends State<MisPagosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfertasProvider>().cargarMisPagos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OfertasProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de pagos')),
      body: RefreshIndicator(
        onRefresh: () => provider.cargarMisPagos(),
        child: _cuerpo(provider),
      ),
    );
  }

  Widget _cuerpo(OfertasProvider provider) {
    if (provider.isLoading && provider.misPagos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.misPagos.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        children: [
          Icon(Icons.cloud_off, size: 44, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(provider.errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => provider.cargarMisPagos(),
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (provider.misPagos.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 44, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'Sin pagos todavia',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Aqui aparecen los cobros de cada oferta que publiques.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: provider.misPagos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _TarjetaPago(pago: provider.misPagos[i]),
    );
  }
}

class _TarjetaPago extends StatelessWidget {
  final PagoModel pago;

  const _TarjetaPago({required this.pago});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fecha = pago.createdAt == null
        ? null
        : DateFormat('d MMM yyyy, h:mm a', 'es').format(pago.createdAt!.toLocal());

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: pago.aprobado
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.errorContainer,
          child: Icon(
            pago.aprobado ? Icons.check : Icons.close,
            color: pago.aprobado
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onErrorContainer,
          ),
        ),
        title: Text(pago.montoTexto, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fecha != null) Text(fecha, style: theme.textTheme.bodySmall),
            if (pago.last4 != null)
              Text('Tarjeta ****${pago.last4}', style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Chip(
          label: Text(pago.aprobado ? 'Aprobado' : 'Rechazado'),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}