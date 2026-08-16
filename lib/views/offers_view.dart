import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/offer_provider.dart';
import '../utils/routes.dart';
import '../widgets/offer_card.dart';

class OffersView extends StatefulWidget {
  const OffersView({super.key});

  @override
  State<OffersView> createState() => _OffersViewState();
}

class _OffersViewState extends State<OffersView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferProvider>().loadOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final offersProvider = context.watch<OfferProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar ofertas'),
      ),
      body: _buildBody(offersProvider),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  provider.loadOffers();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.offers.isEmpty) {
      return const Center(
        child: Text(
          'No hay ofertas disponibles.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadOffers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.offers.length,
        itemBuilder: (context, index) {
          final offer = provider.offers[index];

          return OfferCard(
            offer: offer,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.offerDetail,
                arguments: offer.id,
              );
            },
          );
        },
      ),
    );
  }
}