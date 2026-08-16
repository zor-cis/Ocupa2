import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/oferta_model.dart';
import '../providers/ofertas_provider.dart';
import '../utils/constants.dart';

class PublicarOfertaView extends StatefulWidget {
  const PublicarOfertaView({super.key});

  @override
  State<PublicarOfertaView> createState() => _PublicarOfertaViewState();
}

class _PublicarOfertaViewState extends State<PublicarOfertaView> {
  final _formKey = GlobalKey<FormState>();

  // Datos del trabajo
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _amount = TextEditingController();

  // Datos de la tarjeta
  final _cardNumber = TextEditingController();
  final _cvv = TextEditingController();
  final _expMonth = TextEditingController();
  final _expYear = TextEditingController();
  final _cardholder = TextEditingController();

  String? _jobTypeKey;
  String _contractType = 'temporal';
  DateTime? _deadline;
  File? _foto;

  /// Respuestas a los campos extra que exige el tipo de trabajo.
  final Map<String, String> _customAnswers = {};

  static const _contractTypes = ['temporal', 'fijo', 'horas'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfertasProvider>().cargarJobTypes();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _description,
      _address,
      _amount,
      _cardNumber,
      _cvv,
      _expMonth,
      _expYear,
      _cardholder,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _elegirFoto() async {
    try {
      final foto = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (foto != null) setState(() => _foto = File(foto.path));
    } catch (_) {
      _aviso('No se pudo abrir la galeria. Revisa los permisos.');
    }
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy.add(const Duration(days: 7)),
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365)),
    );
    if (fecha != null) setState(() => _deadline = fecha);
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_foto == null) {
      _aviso('La foto es obligatoria para publicar.');
      return;
    }

    final provider = context.read<OfertasProvider>();

    final ok = await provider.publicarOferta(
      foto: _foto!,
      jobTypeKey: _jobTypeKey!,
      contractType: _contractType,
      description: _description.text.trim(),
      address: _address.text.trim(),
      amount: double.parse(_amount.text.trim()),
      cardNumber: _cardNumber.text.trim(),
      cvv: _cvv.text.trim(),
      expMonth: int.parse(_expMonth.text.trim()),
      expYear: int.parse(_expYear.text.trim()),
      cardholder: _cardholder.text.trim(),
      deadline: _deadline,
      customAnswers: _customAnswers.isEmpty ? null : _customAnswers,
    );

    if (!mounted) return;

    if (ok) {
      _aviso('Oferta publicada');
      Navigator.pop(context, true);
    } else {
      _aviso(provider.errorMessage ?? 'No se pudo publicar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OfertasProvider>();
    final jobType = provider.jobTypePorKey(_jobTypeKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar oferta')),
      body: AbsorbPointer(
        absorbing: provider.isLoading,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              // ---------- Trabajo ----------
              Text('Sobre el trabajo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _jobTypeKey,
                decoration: const InputDecoration(
                  labelText: 'Tipo de trabajo',
                  border: OutlineInputBorder(),
                ),
                items: provider.jobTypes
                    .map((t) => DropdownMenuItem(value: t.key, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _jobTypeKey = v;
                  _customAnswers.clear();
                }),
                validator: (v) => v == null ? 'Elige un tipo de trabajo' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _contractType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de contrato',
                  border: OutlineInputBorder(),
                ),
                items: _contractTypes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _contractType = v!),
              ),
              const SizedBox(height: 16),

              // Campos extra que exige el tipo de trabajo elegido
              if (jobType != null)
                for (final campo in jobType.customFields) ...[
                  _CampoExtra(
                    campo: campo,
                    valor: _customAnswers[campo.key],
                    onChanged: (v) => _customAnswers[campo.key] = v,
                  ),
                  const SizedBox(height: 16),
                ],

              TextFormField(
                controller: _description,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripcion',
                  hintText: 'Que hay que hacer, cuantas horas, que debe traer...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 20)
                    ? 'Describe el trabajo con al menos 20 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _address,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Direccion',
                  hintText: 'Santo Domingo Oeste',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Indica donde es el trabajo' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(
                  labelText: 'Cuanto vas a pagar',
                  prefixText: 'RD\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final monto = double.tryParse(v?.trim() ?? '');
                  if (monto == null || monto <= 0) return 'Escribe el monto en numeros';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _elegirFecha,
                icon: const Icon(Icons.event),
                label: Text(
                  _deadline == null
                      ? 'Fecha limite (opcional)'
                      : 'Hasta ${_deadline!.toIso8601String().split('T').first}',
                ),
              ),
              const SizedBox(height: 24),

              // ---------- Foto ----------
              Text('Foto (obligatoria)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _SelectorFoto(
                foto: _foto,
                onElegir: _elegirFoto,
                onQuitar: () => setState(() => _foto = null),
              ),
              const SizedBox(height: 28),

              // ---------- Pago ----------
              Text('Pago de publicacion', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Publicar cuesta US\$${ApiConstants.costoPublicacion.toStringAsFixed(0)}. '
                'Se cobra al enviar el formulario.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cardholder,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Nombre en la tarjeta',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Escribe el nombre' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cardNumber,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  labelText: 'Numero de tarjeta',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length < 15)
                    ? 'Numero de tarjeta invalido'
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expMonth,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Mes',
                        hintText: '12',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final m = int.tryParse(v ?? '');
                        if (m == null || m < 1 || m > 12) return 'Mes';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _expYear,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Ano',
                        hintText: '2030',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final y = int.tryParse(v ?? '');
                        if (y == null || y < DateTime.now().year) return 'Ano';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvv,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().length < 3) ? 'CVV' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ayuda para probar (pasarela simulada del profesor)
              Text(
                'Tarjeta de prueba: ${ApiConstants.tarjetaAprobada}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: provider.isLoading ? null : _publicar,
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Pagar US\$${ApiConstants.costoPublicacion.toStringAsFixed(0)} y publicar',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo dinamico que exige el tipo de trabajo (ej. categoria de licencia).
class _CampoExtra extends StatelessWidget {
  final CustomFieldModel campo;
  final String? valor;
  final ValueChanged<String> onChanged;

  const _CampoExtra({
    required this.campo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (campo.type == 'select' && campo.options.isNotEmpty) {
      return DropdownButtonFormField<String>(
        initialValue: valor,
        decoration: InputDecoration(
          labelText: campo.label,
          border: const OutlineInputBorder(),
        ),
        items: campo.options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) => onChanged(v!),
        validator: (v) =>
            (campo.required && v == null) ? 'Elige ${campo.label.toLowerCase()}' : null,
      );
    }

    return TextFormField(
      initialValue: valor,
      decoration: InputDecoration(
        labelText: campo.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: (v) => (campo.required && (v == null || v.trim().isEmpty))
          ? 'Completa ${campo.label.toLowerCase()}'
          : null,
    );
  }
}

class _SelectorFoto extends StatelessWidget {
  final File? foto;
  final VoidCallback onElegir;
  final VoidCallback onQuitar;

  const _SelectorFoto({
    required this.foto,
    required this.onElegir,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    if (foto == null) {
      return InkWell(
        onTap: onElegir,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined),
              SizedBox(height: 8),
              Text('Agregar una foto', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(foto!, height: 180, width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onQuitar,
              tooltip: 'Quitar foto',
            ),
          ),
        ),
      ],
    );
  }
}