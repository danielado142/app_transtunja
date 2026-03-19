import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_transtunja/services/routing_service.dart';
import 'package:app_transtunja/services/ruta_service.dart';

class HistorialRutas extends StatefulWidget {
  const HistorialRutas({super.key, this.apiBaseUrl = '/transtunja'});

  final String apiBaseUrl;

  @override
  State<CrearRuta> createState() => _CrearRutaState();
}

class _CrearRutaState extends State<CrearRuta> {
  final MapController _mapController = MapController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();

  late final RutaService _rutaService;
  late final RoutingService _routingService;

  bool _isSaving = false;
  bool _isRouting = false;

  List<LatLng> _waypoints = [];
  List<LatLng> _polylinePoints = [];

  int? _selectedMarkerIndex;

  Timer? _routeDebounce;
  int _routeRequestId = 0;

  static const LatLng _tunjaCenter = LatLng(5.5353, -73.3678);

  @override
  void initState() {
    super.initState();
    _rutaService = RutaService(baseUrl: widget.apiBaseUrl);
    _routingService = RoutingService();
  }

  @override
  void dispose() {
    _routeDebounce?.cancel();
    _nombreCtrl.dispose();
    _destinoCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Future<void> _handleMapTap(LatLng tappedPoint) async {
    if (_isSaving) return;

    if (_selectedMarkerIndex != null) {
      await _moveSelectedMarker(tappedPoint);
      return;
    }

    await _addPoint(tappedPoint);
  }

  Future<void> _addPoint(LatLng point) async {
    try {
      final snapped = await _routingService.snapPointToRoad(point);

      if (!mounted) return;

      setState(() {
        _waypoints.add(snapped);
      });

      _scheduleRouteRebuild();
    } catch (e) {
      _showSnack('No se pudo agregar el punto: $e', isError: true);
    }
  }

  Future<void> _moveSelectedMarker(LatLng point) async {
    final index = _selectedMarkerIndex;
    if (index == null) return;

    try {
      final snapped = await _routingService.snapPointToRoad(point);

      if (!mounted) return;

      setState(() {
        _waypoints[index] = snapped;
        _selectedMarkerIndex = null;
      });

      _scheduleRouteRebuild();
    } catch (e) {
      _showSnack('No se pudo mover el marcador: $e', isError: true);
    }
  }

  void _removePoint(int index) {
    if (_waypoints.length <= 2) {
      _showSnack('La ruta debe tener al menos 2 puntos.', isError: true);
      return;
    }

    setState(() {
      _waypoints.removeAt(index);
      _selectedMarkerIndex = null;
    });

    _scheduleRouteRebuild();
  }

  void _scheduleRouteRebuild() {
    _routeDebounce?.cancel();
    _routeDebounce = Timer(const Duration(milliseconds: 500), _rebuildPolyline);
  }

  Future<void> _rebuildPolyline() async {
    if (_waypoints.length < 2) {
      setState(() {
        _polylinePoints = List<LatLng>.from(_waypoints);
      });
      return;
    }

    final requestId = ++_routeRequestId;

    setState(() {
      _isRouting = true;
    });

    try {
      final polyline = await _routingService.buildRoadPolyline(_waypoints);

      if (!mounted || requestId != _routeRequestId) return;

      setState(() {
        _polylinePoints = polyline;
      });
    } catch (_) {
      if (!mounted || requestId != _routeRequestId) return;

      setState(() {
        _polylinePoints = List<LatLng>.from(_waypoints);
      });

      _showSnack(
        'No se pudo ajustar la ruta a las calles. Se dejó el trazado manual.',
        isError: true,
      );
    } finally {
      if (!mounted || requestId != _routeRequestId) return;

      setState(() {
        _isRouting = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _nombreCtrl.clear();
      _destinoCtrl.clear();
      _waypoints.clear();
      _polylinePoints.clear();
      _selectedMarkerIndex = null;
    });

    _showSnack('Formulario restablecido.');
  }

  bool _validateBeforeSave() {
    if (_nombreCtrl.text.trim().isEmpty || _destinoCtrl.text.trim().isEmpty) {
      _showSnack('Completa nombre y destino.', isError: true);
      return false;
    }

    if (_waypoints.length < 2) {
      _showSnack('Debes marcar al menos 2 puntos en el mapa.', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _guardarRuta() async {
    if (!_validateBeforeSave()) return;

    _routeDebounce?.cancel();

    setState(() {
      _isSaving = true;
    });

    try {
      if (_polylinePoints.length < 2) {
        await _rebuildPolyline();
      }

      final routeId = 'R-${DateTime.now().millisecondsSinceEpoch}';

      final resultado = await _rutaService.guardarRuta(
        routeId: routeId,
        nombre: _nombreCtrl.text,
        destino: _destinoCtrl.text,
        waypoints: _waypoints,
        polylinePoints: _polylinePoints.length >= 2
            ? _polylinePoints
            : _waypoints,
      );

      if (!mounted) return;

      if (resultado['success'] == true || resultado['ok'] == true) {
        _showSnack('Ruta guardada correctamente.');
        Navigator.pop(context, true);
      } else {
        _showSnack(
          resultado['message']?.toString() ?? 'No se pudo guardar la ruta.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error al guardar: $e', isError: true);
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _tunjaCenter,
          initialZoom: 14.5,
          onTap: (_, point) => _handleMapTap(point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.transtunja.admin',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          if (_polylinePoints.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _polylinePoints,
                  strokeWidth: 5.0,
                  color: Colors.red,
                ),
              ],
            ),
          MarkerLayer(
            markers: List.generate(_waypoints.length, (index) {
              final isSelected = _selectedMarkerIndex == index;

              return Marker(
                point: _waypoints[index],
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMarkerIndex = isSelected ? null : index;
                    });
                  },
                  onLongPress: () => _removePoint(index),
                  child: Icon(
                    Icons.location_on,
                    size: 40,
                    color: isSelected ? Colors.amber : Colors.red,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre de la ruta',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _destinoCtrl,
            decoration: const InputDecoration(
              labelText: 'Destino',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text('Puntos: ${_waypoints.length}'),
                avatar: const Icon(Icons.alt_route, size: 18),
              ),
              Chip(
                label: Text(
                  _selectedMarkerIndex == null
                      ? 'Modo: agregar'
                      : 'Mover marcador ${_selectedMarkerIndex! + 1}',
                ),
                avatar: const Icon(Icons.edit_location_alt, size: 18),
              ),
              Chip(
                label: Text(_isRouting ? 'Ajustando a vías...' : 'Ruta lista'),
                avatar: Icon(
                  _isRouting ? Icons.sync : Icons.check_circle,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Toca el mapa para agregar un punto. '
              'Toca un marcador y luego el mapa para moverlo. '
              'Mantén presionado un marcador para eliminarlo.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : _clearForm,
            child: const Text('Restablecer'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _guardarRuta,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Guardar ruta'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Ruta')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTopPanel(),
            const SizedBox(height: 12),
            Expanded(child: _buildMap()),
            const SizedBox(height: 12),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }
}
