import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/oferta_model.dart';
import '../providers/ofertas_provider.dart';
import 'aplicantes_view.dart';
import 'mis_pagos_view.dart';
import 'publicar_oferta_view.dart';

class MisOfertasView extends StatefulWidget {
  const MisOfertasView({super.key});

  @override
  State<MisOfertasView> createState() => _MisOfertasViewState();
}

class _MisOfertasViewState extends State<MisOfertasView> {
  @override
  void initState() {
    super.initState();
    // Despues del primer frame, para poder usar el context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfertasProvider>().cargarMisOfertas();
    });
  }

  Future<void> _desactivar(OfertaModel oferta) async {
    final provider = context.read<OfertasProvider>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desactivar oferta'),
        content: const Text(
          'Deja de aparecer en el listado publico y no admite nuevas aplicaciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final ok = await provider.desactivarOferta(oferta.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Oferta desactivada' : provider.errorMessage ?? 'No se pudo'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OfertasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis ofertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Historial de pagos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisPagosView()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final creada = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PublicarOfertaView()),
          );
          if (creada == true && context.mounted) {
            context.read<OfertasProvider>().cargarMisOfertas();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.cargarMisOfertas(),
        child: _cuerpo(provider),
      ),
    );
  }

  Widget _cuerpo(OfertasProvider provider) {
    if (provider.isLoading && provider.misOfertas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.misOfertas.isEmpty) {
      return _Mensaje(
        icono: Icons.cloud_off,
        titulo: 'No se pudo cargar',
        detalle: provider.errorMessage!,
        accion: FilledButton(
          onPressed: () => provider.cargarMisOfertas(),
          child: const Text('Reintentar'),
        ),
      );
    }

    if (provider.misOfertas.isEmpty) {
      return const _Mensaje(
        icono: Icons.work_outline,
        titulo: 'Todavia no has publicado nada',
        detalle: 'Publica un trabajo y en minutos empiezas a recibir aplicaciones.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: provider.misOfertas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final oferta = provider.misOfertas[i];
        return _TarjetaOferta(
          oferta: oferta,
          onVerAplicantes: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AplicantesView(
                ofertaId: oferta.id,
                titulo: oferta.tipoTexto,
              ),
            ),
          ),
          onDesactivar: () => _desactivar(oferta),
        );
      },
    );
  }
}

class _TarjetaOferta extends StatelessWidget {
  final OfertaModel oferta;
  final VoidCallback onVerAplicantes;
  final VoidCallback onDesactivar;

  const _TarjetaOferta({
    required this.oferta,
    required this.onVerAplicantes,
    required this.onDesactivar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (oferta.photo != null && oferta.photo!.isNotEmpty)
            Image.network(
              oferta.photo!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(oferta.tipoTexto, style: theme.textTheme.titleMedium),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      oferta.montoTexto,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  oferta.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                if (oferta.address != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          oferta.address!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(oferta.estadoTexto),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text(oferta.contractType),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text('${oferta.totalApplications} aplicantes'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onVerAplicantes,
                        icon: const Icon(Icons.people_outline, size: 18),
                        label: const Text('Ver aplicantes'),
                      ),
                    ),
                    if (oferta.activa) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDesactivar,
                        icon: const Icon(Icons.block),
                        tooltip: 'Desactivar',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final Widget? accion;

  const _Mensaje({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    // ListView para que el pull-to-refresh funcione aunque este vacio.
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      children: [
        Icon(icono, size: 44, color: Theme.of(context).disabledColor),
        const SizedBox(height: 16),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          detalle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (accion != null) ...[const SizedBox(height: 20), accion!],
      ],
    );
  }
}