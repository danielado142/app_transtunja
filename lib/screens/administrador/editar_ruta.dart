import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_transtunja/services/routing_service.dart';
import 'package:app_transtunja/services/ruta_service.dart';

class EditarRuta extends StatefulWidget {
  const EditarRuta({
    super.key,
    required this.routeId,
    this.apiBaseUrl = '/transtunja',
  });

  final String routeId;
  final String apiBaseUrl;

  @override
  State<EditarRuta> createState() => _EditarRutaState();
}

class _EditarRutaState extends State<EditarRuta> {
  final MapController _mapController = MapController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();

  late final RutaService _rutaService;
  late final RoutingService _routingService;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRouting = false;

  String _originalNombre = '';
  String _originalDestino = '';
  List<LatLng> _originalWaypoints = [];
  List<LatLng> _originalPolyline = [];

  List<LatLng> _waypoints = [];
  List<LatLng> _polylinePoints = [];

  int? _selectedMarkerIndex;
  final List<String> _history = [];

  Timer? _routeDebounce;
  int _routeRequestId = 0;

  static const LatLng _tunjaCenter = LatLng(5.5353, -73.3678);

  @override
  void initState() {
    super.initState();
    _rutaService = RutaService(baseUrl: widget.apiBaseUrl);
    _routingService = RoutingService();
    _loadRoute();
  }

  @override
  void dispose() {
    _routeDebounce?.cancel();
    _nombreCtrl.dispose();
    _destinoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    try {
      final route = await _rutaService.fetchRouteById(widget.routeId);

      _originalNombre = route.nombre;
      _originalDestino = route.destino;
      _originalWaypoints = List<LatLng>.from(route.waypoints);
      _originalPolyline = List<LatLng>.from(route.polylinePoints);

      _nombreCtrl.text = route.nombre;
      _destinoCtrl.text = route.destino;
      _waypoints = List<LatLng>.from(route.waypoints);
      _polylinePoints = List<LatLng>.from(route.polylinePoints);

      if (!mounted) return;

      _pushHistory('Ruta cargada desde base de datos');

      setState(() {
        _isLoading = false;
      });

      if (_waypoints.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(_waypoints.first, 14.8);
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnack('Error cargando la ruta: $e', isError: true);
    }
  }

  void _pushHistory(String text) {
    final now = TimeOfDay.now().format(context);
    _history.insert(0, '$now · $text');
    if (_history.length > 8) {
      _history.removeLast();
    }
  }

  void _showSnack(String text, {bool isError = false}) {
    if (!mounted) return;

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
        _pushHistory('Punto ${_waypoints.length} agregado');
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
        _pushHistory('Marcador ${index + 1} movido');
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
      _pushHistory('Marcador ${index + 1} eliminado');
    });

    _scheduleRouteRebuild();
  }

  void _scheduleRouteRebuild() {
    _routeDebounce?.cancel();
    _routeDebounce = Timer(const Duration(milliseconds: 500), _rebuildPolyline);
  }

  Future<void> _rebuildPolyline() async {
    if (_waypoints.length < 2) {
      if (!mounted) return;
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
        'No se pudo ajustar la ruta a las calles. Se dejó la geometría manual.',
        isError: true,
      );
    } finally {
      if (!mounted || requestId != _routeRequestId) return;

      setState(() {
        _isRouting = false;
      });
    }
  }

  void _resetChanges() {
    _routeDebounce?.cancel();

    setState(() {
      _nombreCtrl.text = _originalNombre;
      _destinoCtrl.text = _originalDestino;
      _waypoints = List<LatLng>.from(_originalWaypoints);
      _polylinePoints = List<LatLng>.from(_originalPolyline);
      _selectedMarkerIndex = null;
      _pushHistory('Datos restaurados');
    });

    _showSnack('Los datos fueron restaurados.');
  }

  bool _validateBeforeSave() {
    if (_nombreCtrl.text.trim().isEmpty || _destinoCtrl.text.trim().isEmpty) {
      _showSnack('Nombre de ruta y destino son obligatorios.', isError: true);
      return false;
    }

    if (_waypoints.length < 2) {
      _showSnack('Debes tener al menos 2 puntos en el mapa.', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _saveChanges() async {
    if (!_validateBeforeSave()) return;

    _routeDebounce?.cancel();

    setState(() {
      _isSaving = true;
    });

    try {
      if (_polylinePoints.length < 2) {
        await _rebuildPolyline();
      }

      final resultado = await _rutaService.updateRoute(
        routeId: widget.routeId,
        nombre: _nombreCtrl.text,
        destino: _destinoCtrl.text,
        waypoints: _waypoints,
        polylinePoints: _polylinePoints.length >= 2
            ? _polylinePoints
            : _waypoints,
      );

      if (!mounted) return;

      if (resultado['success'] == true || resultado['ok'] == true) {
        _showSnack('Ruta actualizada correctamente.');
        Navigator.pop(context, true);
      } else {
        _showSnack(
          resultado['message']?.toString() ?? 'No se pudo actualizar la ruta.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('No se pudo guardar: $e', isError: true);
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildTopForm() {
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

  Widget _buildMap() {
    final initialCenter = _waypoints.isNotEmpty
        ? _waypoints.first
        : _tunjaCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: initialCenter,
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
                      _pushHistory(
                        isSelected
                            ? 'Marcador ${index + 1} deseleccionado'
                            : 'Marcador ${index + 1} seleccionado',
                      );
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

  Widget _buildHistoryPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.history),
              SizedBox(width: 8),
              Text(
                'Historial de edición',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: _history.isEmpty
                ? const Center(child: Text('Sin cambios todavía'))
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('• ${_history[index]}'),
                      );
                    },
                  ),
          ),
          if (_isRouting)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _resetChanges,
                  child: const Text('Restablecer'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Ruta')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTopForm(),
                  const SizedBox(height: 12),
                  Expanded(child: _buildMap()),
                  const SizedBox(height: 12),
                  _buildHistoryPanel(),
                ],
              ),
            ),
    );
  }
}
