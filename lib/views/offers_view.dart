import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/offer_provider.dart';
import '../utils/routes.dart';
import '../widgets/offer_card.dart';
import 'publicar_oferta_view.dart';

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
      final provider = context.read<OfferProvider>();
      provider.loadJobTypes();
      provider.loadOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final offersProvider = context.watch<OfferProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar ofertas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final creada = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PublicarOfertaView()),
          );
          if (creada == true && mounted) {
            context.read<OfferProvider>().loadOffers();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
      body: Column(
        children: [
          _buildFilter(offersProvider),
          Expanded(child: _buildBody(offersProvider)),
        ],
      ),
    );
  }

  Widget _buildFilter(OfferProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: provider.currentJobTypeKey,
                hint: const Text('Filtrar por tipo de empleo'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos los empleos'),
                  ),
                  ...provider.jobTypes.map((type) {
                    return DropdownMenuItem<String?>(
                      value: type.key,
                      child: Text(type.name),
                    );
                  }),
                ],
                onChanged: (String? newValue) {
                  provider.loadOffers(jobTypeKey: newValue);
                },
              ),
            ),
          ),
        ],
      ),
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
                  provider.loadOffers(jobTypeKey: provider.currentJobTypeKey);
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