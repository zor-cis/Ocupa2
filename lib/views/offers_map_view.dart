import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;

import '../providers/offer_provider.dart';
import '../utils/routes.dart';

class OffersMapView extends StatefulWidget {
  const OffersMapView({super.key});

  @override
  State<OffersMapView> createState() => _OffersMapViewState();
}

class _OffersMapViewState extends State<OffersMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = true;

  // Parámetros de filtrado por distancia
  double _maxDistanceKm = 5.0;
  double _minDistanceKm = 0.0;
  bool _isLimitEnabled = true;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(18.7357, -70.1627),
    zoom: 8,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      await _getCurrentLocation();
      if (!mounted) return;
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      await offerProvider.loadOffers();
      if (!mounted) return;
      _createMarkers();
    } catch (e) {
      debugPrint('Error inicializando mapa: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (!mounted) return;
      
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            14,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
    }
  }

  void _createMarkers() {
    try {
      final offers = context.read<OfferProvider>().offers;
      final Set<Marker> newMarkers = {};

      for (final offer in offers) {
        double distance = 0;
        if (_currentPosition != null) {
          distance = _calculateDistance(
            _currentPosition!.latitude, 
            _currentPosition!.longitude, 
            offer.location.lat, 
            offer.location.lng
          );
        }

        if (!_isLimitEnabled || _currentPosition == null || 
            (distance >= _minDistanceKm && distance <= _maxDistanceKm)) {
          newMarkers.add(
            Marker(
              markerId: MarkerId(offer.id.toString()),
              position: LatLng(offer.location.lat, offer.location.lng),
              infoWindow: InfoWindow(
                title: offer.jobTypeName,
                snippet: '${offer.payment.amount} ${offer.payment.currency}',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.offerDetail,
                    arguments: offer.id,
                  );
                },
              ),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.addAll(newMarkers);
        });
      }
    } catch (e) {
      debugPrint('Error creando marcadores: $e');
    }
  }

  // Fórmula de Haversine para calcular distancia entre dos puntos
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Ofertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filtrar distancia',
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _currentPosition != null 
              ? CameraPosition(
                  target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  zoom: 14)
              : _defaultPosition,
            markers: _markers,
            onMapCreated: (controller) {
              if (mounted) {
                _mapController = controller;
                if (_currentPosition != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      14,
                    ),
                  );
                }
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),
          // Botón para centrar en mi ubicación
          if (_currentPosition != null)
            Positioned(
              bottom: 100,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      14,
                    ),
                  );
                },
                child: const Icon(Icons.my_location),
              ),
            ),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_isLimitEnabled 
                      ? 'Buscando ofertas cercanas (${_maxDistanceKm.toInt()}km)...'
                      : 'Buscando todas las ofertas...'),
                  ],
                ),
              ),
            ),
          if (!_isLoading && _markers.isEmpty)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.blue.withValues(alpha: 0.9),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _isLimitEnabled 
                      ? 'No hay ofertas entre ${_minDistanceKm.toInt()}km y ${_maxDistanceKm.toInt()}km de tu ubicación.'
                      : 'No hay ofertas disponibles en este momento.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtro de Distancia',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _isLimitEnabled,
                        onChanged: (value) {
                          setState(() => _isLimitEnabled = value);
                          setSheetState(() => _isLimitEnabled = value);
                          _createMarkers();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLimitEnabled 
                      ? 'Mostrar ofertas dentro de un rango específico.'
                      : 'Mostrando todas las ofertas sin límite de distancia.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (_isLimitEnabled) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rango: ${_minDistanceKm.toInt()}km - ${_maxDistanceKm.toInt()}km'),
                        const Icon(Icons.straighten, color: Colors.blue),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_minDistanceKm, _maxDistanceKm),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      labels: RangeLabels(
                        '${_minDistanceKm.toInt()} km',
                        '${_maxDistanceKm.toInt()} km',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _minDistanceKm = values.start;
                          _maxDistanceKm = values.end;
                        });
                        setSheetState(() {
                          _minDistanceKm = values.start;
                          _maxDistanceKm = values.end;
                        });
                        _createMarkers();
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
