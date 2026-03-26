import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:app_transtunja/config/constants.dart';
import 'package:app_transtunja/services/routing_service.dart';

class CrearRuta extends StatefulWidget {
  const CrearRuta({
    super.key,
    this.apiBaseUrl = '',
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

  static const LatLng _tunjaCenter = LatLng(5.5353, -73.3678);

  final MapController _mapController = MapController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();
  final TextEditingController _idRutaCtrl = TextEditingController();

  late final RoutingService _routingService;

  bool _isSaving = false;
  bool _isRouting = false;

  List<LatLng> _waypoints = [];
  List<LatLng> _polylinePoints = [];

  int? _selectedMarkerIndex;
  Timer? _routeDebounce;
  int _routeRequestId = 0;

  String get _baseUrl {
    final custom = widget.apiBaseUrl.trim();
    if (custom.startsWith('http://') || custom.startsWith('https://')) {
      return custom;
    }
    return ApiConfig.baseUrl;
  }

  @override
  void initState() {
    super.initState();
    _routingService = RoutingService();
  }

  @override
  void dispose() {
    _routeDebounce?.cancel();
    _nombreCtrl.dispose();
    _destinoCtrl.dispose();
    _idRutaCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _showSnack(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _waypoints.add(point);
      });
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
    } catch (_) {
      if (!mounted) return;
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
      _idRutaCtrl.clear();
      _waypoints.clear();
      _polylinePoints.clear();
      _selectedMarkerIndex = null;
    });
    _mapController.move(_tunjaCenter, 14.5);
  }

  // --- MÉTODO DE GUARDADO FINAL CORREGIDO CON USER-AGENT ---
  Future<void> _guardarRuta() async {
    if (_nombreCtrl.text.trim().isEmpty ||
        _destinoCtrl.text.trim().isEmpty ||
        _idRutaCtrl.text.trim().isEmpty ||
        _waypoints.length < 2) {
      _showSnack('Completa todos los campos y marca la ruta', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final List<List<double>> formatoCoordenadas =
          (_polylinePoints.isNotEmpty ? _polylinePoints : _waypoints)
              .map((p) => [p.latitude, p.longitude])
              .toList();

      final List<List<double>> formatoWaypoints =
          _waypoints.map((p) => [p.latitude, p.longitude]).toList();

      // Limpieza de URL para evitar errores de red
      final String endpoint = '${_baseUrl.trim()}/guardar_ruta.php'
          .replaceFirst('//guardar_ruta', '/guardar_ruta');
      final url = Uri.parse(endpoint);

      print("--- INICIANDO PETICIÓN CON USER-AGENT ---");
      print("URL destino: $url");

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              // Engañamos al servidor para que crea que somos un navegador
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            },
            body: jsonEncode({
              'id_ruta': _idRutaCtrl.text.trim(),
              'nombre': _nombreCtrl.text.trim(),
              'destino': _destinoCtrl.text.trim(),
              'coordenadas': formatoCoordenadas,
              'waypoitns': formatoWaypoints,
            }),
          )
          .timeout(const Duration(seconds: 15));

      // Diagnóstico detallado en consola
      print("CÓDIGO DE ESTADO: ${response.statusCode}");
      print("RESPUESTA CRUDA: '${response.body}'");

      if (response.body.trim().isEmpty) {
        throw Exception(
            "El servidor respondió vacío. Posible bloqueo de Firewall.");
      }

      final resultado = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && resultado['status'] == 'success') {
        _showSnack('✅ Ruta guardada con éxito');
        _clearForm();
      } else {
        _showSnack('Error: ${resultado['message'] ?? 'Respuesta inválida'}',
            isError: true);
      }
    } catch (e) {
      print("DETALLE DEL ERROR: $e");
      _showSnack('Error de conexión: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.black54),
      filled: true,
      fillColor: colorCard,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: colorRojoApp, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: colorRojoApp,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text('CREAR RUTA',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.white)),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTopPanel(),
            if (_isRouting) const LinearProgressIndicator(color: colorRojoApp),
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
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    if (_polylinePoints.length >= 2)
                      PolylineLayer(polylines: [
                        Polyline(
                            points: _polylinePoints,
                            strokeWidth: 5,
                            color: Colors.blue),
                      ]),
                    MarkerLayer(
                      markers: _waypoints.asMap().entries.map((entry) {
                        return Marker(
                          point: entry.value,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMarkerIndex =
                                (_selectedMarkerIndex == entry.key
                                    ? null
                                    : entry.key)),
                            onLongPress: () => _removePoint(entry.key),
                            child: Icon(Icons.location_on,
                                size: 40,
                                color: _selectedMarkerIndex == entry.key
                                    ? Colors.orange
                                    : Colors.red),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
                controller: _nombreCtrl,
                decoration:
                    _inputDecoration(label: 'Nombre Ruta', icon: Icons.route)),
            const SizedBox(height: 10),
            TextField(
                controller: _destinoCtrl,
                decoration:
                    _inputDecoration(label: 'Destino Final', icon: Icons.flag)),
            const SizedBox(height: 10),
            TextField(
                controller: _idRutaCtrl,
                decoration: _inputDecoration(
                    label: 'ID Ruta (Ej: R-01)', icon: Icons.numbers)),
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
            onPressed: _isSaving ? null : _clearForm,
            style: OutlinedButton.styleFrom(
              backgroundColor: colorLimpiarBg,
              side: const BorderSide(color: colorLimpiarBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Limpiar',
                style: TextStyle(color: colorLimpiarBorder)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _guardarRuta,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojoApp,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
