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

  final _commentController = TextEditingController();

  final Map<String, TextEditingController> _answerControllers = {};

  @override
  void dispose() {
    _commentController.dispose();

    for (final controller in _answerControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

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

  TextEditingController _getAnswerController(String questionId) {
    return _answerControllers.putIfAbsent(
      questionId,
      () => TextEditingController(),
    );
  }

  Future<void> _apply() async {
    if (_offerId == null) return;

    final comment = _commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes escribir un comentario para aplicar.'),
        ),
      );
      return;
    }

    final provider = context.read<OfferProvider>();
    final offer = provider.selectedOffer;

    if (offer == null) return;

    final answers = <Map<String, dynamic>>[];

    for (final question in offer.questions) {
      final controller = _answerControllers[question.id];

      answers.add({
        'questionId': question.id,
        'value': controller?.text.trim() ?? '',
      });
    }

    final success = await provider.applyToOffer(
      _offerId!,
      comment,
      answers,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Aplicaste correctamente a la oferta!'),
        ),
      );

      Navigator.pop(context);
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

    final offer = provider.selectedOffer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de oferta'),
        actions: [
          if (offer != null)
            IconButton(
              icon: Icon(
                offer.likedByMe ? Icons.favorite : Icons.favorite_border,
                color: offer.likedByMe ? Colors.red : null,
              ),
              onPressed: () {
                provider.toggleLike(offer.id);
              },
            ),
        ],
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
            value:
                '${offer.payment.amount} ${offer.payment.currency} / ${offer.payment.period}',
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 20),
              const SizedBox(width: 6),
              Text(
                '${offer.likesCount} me gusta',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.people, color: Colors.blue, size: 20),
              const SizedBox(width: 6),
              Text(
                '${offer.applicantsCount} aplicantes',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
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

          if (offer.deadline != null) ...[
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha límite',
              value: DateFormat('dd/MM/yyyy').format(offer.deadline!),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            'Aplicar a esta oferta',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Comentario',
              hintText: 'Escribe por qué estás interesado en esta oferta...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
          ),

          if (offer.questions.isNotEmpty) ...[
            const SizedBox(height: 24),

            Text(
              'Preguntas de la oferta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            ...offer.questions.map(
              (question) {
                final controller = _getAnswerController(question.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: question.label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 8),

          CustomButton(
            label: 'Aplicar',
            isLoading: provider.isApplying,
            onPressed: provider.isApplying ? null : _apply,
          ),

          const SizedBox(height: 24),
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