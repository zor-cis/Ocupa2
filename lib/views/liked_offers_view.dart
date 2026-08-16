import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../utils/routes.dart';

class LikedOffersView extends StatefulWidget {
  const LikedOffersView({super.key});

  @override
  State<LikedOffersView> createState() => _LikedOffersViewState();
}

class _LikedOffersViewState extends State<LikedOffersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferProvider>().loadLikedOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Me Gusta'),
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
                    onPressed: () => provider.loadLikedOffers(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.likedOffers.isEmpty) {
            return const Center(
              child: Text('Aún no has dado me gusta a ninguna oferta.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.likedOffers.length,
            itemBuilder: (context, index) {
              final offer = provider.likedOffers[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.offerDetail,
                      arguments: offer.id,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.network(
                        offer.photo,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.jobTypeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.address,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${offer.payment.amount} ${offer.payment.currency}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.red),
                                  onPressed: () => _confirmUnlike(context, offer.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmUnlike(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitar de favoritos'),
        content: const Text('¿Estás seguro de que quieres quitar el "Me gusta" a esta oferta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<OfferProvider>().unlikeOffer(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eliminado de tus "Me gusta"')),
        );
      }
    }
  }
}
