import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// IMPORTANTE: Esta es la línea que debe estar cargada correctamente
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_transtunja/services/routing_service.dart';
import 'package:app_transtunja/services/ruta_service.dart';

class CrearRuta extends StatefulWidget {
  const CrearRuta({super.key, this.apiBaseUrl = '/transtunja'});

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
    _mapController.dispose();
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
      _showSnack('Trazado manual (ajuste a vía fallido).', isError: true);
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
  }

  Future<void> _guardarRuta() async {
    if (_nombreCtrl.text.isEmpty || _waypoints.length < 2) {
      _showSnack('Nombre y al menos 2 puntos requeridos.', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final routeId = 'R-${DateTime.now().millisecondsSinceEpoch}';
      final resultado = await _rutaService.guardarRuta(
        routeId: routeId,
        nombre: _nombreCtrl.text,
        destino: _destinoCtrl.text,
        waypoints: _waypoints,
        polylinePoints: _polylinePoints.isNotEmpty
            ? _polylinePoints
            : _waypoints,
      );
      if (mounted && resultado['success'] == true) {
        _showSnack('Ruta guardada en XAMPP.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Nueva Ruta')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTopPanel(),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
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
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.transtunja.admin',
                      // Aquí se usa el componente del paquete instalado
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    if (_polylinePoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _polylinePoints,
                            strokeWidth: 5.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _waypoints.asMap().entries.map((entry) {
                        int index = entry.key;
                        LatLng point = entry.value;
                        bool isSelected = _selectedMarkerIndex == index;
                        return Marker(
                          point: point,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _selectedMarkerIndex = isSelected
                                  ? null
                                  : index,
                            ),
                            onLongPress: () => _removePoint(index),
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: isSelected ? Colors.orange : Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre Ruta'),
            ),
            TextField(
              controller: _destinoCtrl,
              decoration: const InputDecoration(labelText: 'Destino Final'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearForm,
            child: const Text('Limpiar'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _guardarRuta,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: _isSaving
                ? const CircularProgressIndicator()
                : const Text('Guardar en BD'),
          ),
        ),
      ],
    );
  }
}
