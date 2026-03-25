import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_transtunja/services/routing_service.dart';
import 'package:app_transtunja/services/ruta_service.dart';
import 'package:app_transtunja/config/constants.dart';

class CrearRuta extends StatefulWidget {
  const CrearRuta({
    super.key,
    this.apiBaseUrl = '/transtunja',
    this.showAppBar = true,
  });

  final String apiBaseUrl;
  final bool showAppBar;

  @override
  State<CrearRuta> createState() => _CrearRutaState();
}

class _CrearRutaState extends State<CrearRuta> {
  static const Color colorRojoApp = Color(0xFFD10000);
  static const Color colorFondo = Color(0xFFF6F6F7);
  static const Color colorCard = Color(0xFFFFFFFF);
  static const Color colorTextoPrincipal = Color(0xFF000000);
  static const Color colorLimpiarBg = Color(0xFFFFE5E5);
  static const Color colorLimpiarBorder = Color(0xFF8B0000);

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
        backgroundColor: isError ? Colors.red : Colors.green,
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
      setState(() => _waypoints.add(point));
      _scheduleRouteRebuild();
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
      setState(() {
        _waypoints[index] = point;
        _selectedMarkerIndex = null;
      });
      _scheduleRouteRebuild();
    }
  }

  void _removePoint(int index) {
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
    setState(() => _isRouting = true);

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
    } finally {
      if (!mounted || requestId != _routeRequestId) return;
      setState(() => _isRouting = false);
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

      final List<List<double>> formatoCoordenadas =
          (_polylinePoints.isNotEmpty ? _polylinePoints : _waypoints)
              .map((p) => [p.latitude, p.longitude])
              .toList();

      final List<List<double>> formatoWaypoints =
          _waypoints.map((p) => [p.latitude, p.longitude]).toList();

      final url = Uri.parse('${ApiConfig.baseUrl}/guardar_ruta.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_ruta': routeId,
          'nombre': _nombreCtrl.text,
          'destino': _destinoCtrl.text,
          'coordenadas': formatoCoordenadas,
          'waypoints': formatoWaypoints,
        }),
      );

      if (mounted) {
        final resultado = jsonDecode(response.body);
        if (response.statusCode == 200 && resultado['status'] == 'success') {
          _showSnack('¡Ruta creada y guardada en XAMPP!');
          Navigator.pop(context, true);
        } else {
          _showSnack(
            'Error: ${resultado['message'] ?? 'Error en el servidor'}',
            isError: true,
          );
        }
      }
    } catch (e) {
      _showSnack('Error de conexión: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: colorRojoApp,
              centerTitle: true,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'CREAR RUTA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTopPanel(),
            if (_isRouting)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: colorRojoApp,
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
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
                          final int index = entry.key;
                          final LatLng point = entry.value;
                          final bool isSelected = _selectedMarkerIndex == index;

                          return Marker(
                            point: point,
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _selectedMarkerIndex =
                                    isSelected ? null : index,
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
            ),
            const SizedBox(height: 12),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
    return Container(
      decoration: BoxDecoration(
        color: colorCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              style: const TextStyle(
                fontSize: 14,
                color: colorTextoPrincipal,
              ),
              decoration: const InputDecoration(
                labelText: 'Nombre Ruta',
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                prefixIcon: Icon(
                  Icons.route,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _destinoCtrl,
              style: const TextStyle(
                fontSize: 14,
                color: colorTextoPrincipal,
              ),
              decoration: const InputDecoration(
                labelText: 'Destino Final',
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                prefixIcon: Icon(
                  Icons.flag,
                  color: Colors.black54,
                ),
              ),
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
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _isSaving ? null : _clearForm,
              style: OutlinedButton.styleFrom(
                backgroundColor: colorLimpiarBg,
                side: const BorderSide(
                  color: colorLimpiarBorder,
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Limpiar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colorLimpiarBorder,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _guardarRuta,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorRojoApp,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
