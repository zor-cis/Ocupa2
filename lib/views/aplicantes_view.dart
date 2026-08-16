import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/oferta_model.dart';
import '../providers/ofertas_provider.dart';

class AplicantesView extends StatefulWidget {
  final String ofertaId;
  final String titulo;

  const AplicantesView({
    super.key,
    required this.ofertaId,
    required this.titulo,
  });

  @override
  State<AplicantesView> createState() => _AplicantesViewState();
}

class _AplicantesViewState extends State<AplicantesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfertasProvider>().cargarAplicantes(widget.ofertaId);
    });
  }

  Future<void> _elegir(AplicacionModel aplicacion) async {
    final provider = context.read<OfertasProvider>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elegir ganador'),
        content: Text(
          '${aplicacion.nombre} queda seleccionado para este trabajo. '
          'Esta decision no se puede cambiar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elegir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final ok = await provider.elegirGanador(widget.ofertaId, aplicacion.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Ganador seleccionado' : provider.errorMessage ?? 'No se pudo',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OfertasProvider>();
    final yaHayGanador = provider.aplicantes.any((a) => a.esGanador);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplicantes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.titulo,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.cargarAplicantes(widget.ofertaId),
        child: _cuerpo(provider, yaHayGanador),
      ),
    );
  }

  Widget _cuerpo(OfertasProvider provider, bool yaHayGanador) {
    if (provider.isLoading && provider.aplicantes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.aplicantes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        children: [
          Icon(Icons.cloud_off, size: 44, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(provider.errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => provider.cargarAplicantes(widget.ofertaId),
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (provider.aplicantes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        children: [
          Icon(Icons.people_outline, size: 44, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'Nadie ha aplicado todavia',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Comparte tu oferta o vuelve a revisar en un rato.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: provider.aplicantes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final aplicacion = provider.aplicantes[i];
        return _TarjetaAplicante(
          aplicacion: aplicacion,
          puedeElegir: !yaHayGanador,
          onElegir: () => _elegir(aplicacion),
        );
      },
    );
  }
}

class _TarjetaAplicante extends StatelessWidget {
  final AplicacionModel aplicacion;
  final bool puedeElegir;
  final VoidCallback onElegir;

  const _TarjetaAplicante({
    required this.aplicacion,
    required this.puedeElegir,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              foregroundImage: (aplicacion.foto != null && aplicacion.foto!.isNotEmpty)
                  ? NetworkImage(aplicacion.foto!)
                  : null,
              child: Text(aplicacion.iniciales),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aplicacion.nombre, style: theme.textTheme.titleMedium),
                  if (aplicacion.comment != null && aplicacion.comment!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      aplicacion.comment!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (aplicacion.esGanador)
                    Chip(
                      avatar: const Icon(Icons.emoji_events, size: 16),
                      label: const Text('Ganador'),
                      visualDensity: VisualDensity.compact,
                    )
                  else if (puedeElegir)
                    OutlinedButton(
                      onPressed: onElegir,
                      child: const Text('Elegir'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}